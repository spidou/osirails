class DeliveryIntervention < ActiveRecord::Base
  STATUS_SCHEDULED    = 'scheduled'
  STATUS_DELIVERED    = 'delivered'
  STATUS_UNDELIVERED  = 'undelivered'
  STATUS_POSTPONED    = 'postponed'
  
  has_permissions :as_business_object
  
  has_attached_file :report,
                    :path => ':rails_root/assets/sales/:class/:id.:extension',
                    :url  => '/delivery_interventions/:delivery_intervention_id/report'
  
  belongs_to :delivery_note
  
  ## scheduled
  belongs_to :scheduled_internal_actor,             :class_name => "Employee"
  belongs_to :scheduled_delivery_subcontractor,     :class_name => "Subcontractor"
  belongs_to :scheduled_installation_subcontractor, :class_name => "Subcontractor"
  
  ## reality
  belongs_to :internal_actor,             :class_name => "Employee"
  belongs_to :delivery_subcontractor,     :class_name => "Subcontractor"
  belongs_to :installation_subcontractor, :class_name => "Subcontractor"
  
  # deliverers
  has_many :delivery_interventions_scheduled_deliverers
  has_many :scheduled_deliverers, :through => :delivery_interventions_scheduled_deliverers
  
  has_many :delivery_interventions_deliverers
  has_many :deliverers, :through => :delivery_interventions_deliverers
  
  # installers
  has_many :delivery_interventions_scheduled_installers
  has_many :scheduled_installers, :through => :delivery_interventions_scheduled_installers
  
  has_many :delivery_interventions_installers
  has_many :installers, :through => :delivery_interventions_installers
  
  # vehicles
  has_many :delivery_interventions_scheduled_delivery_vehicles
  has_many :scheduled_delivery_vehicles, :through => :delivery_interventions_scheduled_delivery_vehicles
  
  has_many :delivery_interventions_delivery_vehicles
  has_many :delivery_vehicles, :through => :delivery_interventions_delivery_vehicles
  
  # equipments
  has_many :delivery_interventions_scheduled_installation_equipments
  has_many :scheduled_installation_equipments, :through => :delivery_interventions_scheduled_installation_equipments
  
  has_many :delivery_interventions_installation_equipments
  has_many :installation_equipments, :through => :delivery_interventions_installation_equipments
  
  # discards
  has_many :discards
  
  validates_persistence_of :delivery_note_id
  
  validates_persistence_of  :scheduled_delivery_at,
                            :scheduled_intervention_hours,
                            :scheduled_intervention_minutes,
                            :scheduled_internal_actor_id,
                            :scheduled_delivery_subcontractor_id,
                            :scheduled_delivery_vehicles_rental,
                            :scheduled_delivery_vehicles,
                            :scheduled_deliverers,
                            :scheduled_installation_subcontractor,
                            :scheduled_installation_equipments_rental,
                            :scheduled_installation_equipments,
                            :scheduled_installers, :if => :realized?
  
  validates_persistence_of  :delivery_at,
                            :intervention_hours,
                            :intervention_minutes,
                            :internal_actor_id,
                            :delivery_subcontractor_id,
                            :delivery_vehicles_rental,
                            :delivery_vehicles,
                            :deliverers,
                            :installation_subcontractor,
                            :installation_equipments_rental,
                            :installation_equipments,
                            :installers, :if => :was_realized?
  
  ## if scheduled
  with_options :if => :scheduled? do |x|
    x.validates_presence_of :scheduled_delivery_at, :scheduled_internal_actor_id
    
    x.validate :validates_scheduled_intervention_duration
  end
  
  validates_date :scheduled_delivery_at, :on_or_after => Date.today, :if => Proc.new{ |i| i.scheduled? and i.scheduled_delivery_at_changed? }
  
  validate :validates_scheduled_delivery_subcontracting,      :if => Proc.new{ |i| i.scheduled? and i.delivery? }
  validate :validates_scheduled_installation_subcontracting,  :if => Proc.new{ |i| i.scheduled? and i.installation? }
  
  ## if delivered
  with_options :if => :delivered? do |x|
    x.validates_presence_of :delivery_at, :internal_actor_id
    
    x.validates_date :delivery_at, :on_or_before => Date.today, :on_or_after => Proc.new{ |i| i.delivery_note.published_on }
    
    x.validate :validates_intervention_duration
    x.validate :validates_emptiness_of_postponed
  end
  
  validate :validates_delivery_subcontracting,      :if => Proc.new{ |i| i.delivered? and i.delivery? }
  validate :validates_installation_subcontracting,  :if => Proc.new{ |i| i.delivered? and i.installation? }
  
  ## if undelivered
  with_options :if => :undelivered? do |x|
    x.validate :validates_emptiness_of_all_fields
    x.validate :validates_emptiness_of_postponed
    
    x.validates_presence_of :comments
  end
  
  ## if postponed
  with_options :if => :postponed? do |x|
    x.validate :validates_emptiness_of_all_fields
    x.validate :validates_emptiness_of_comments_and_delivered
  end
  
  validates_associated :delivery_note
  
  after_save :save_discards
  after_save :sign_delivery_note
  
  def validates_scheduled_intervention_duration
    errors.add(:scheduled_intervention_hours, "La durée de l'intervention est requise") if scheduled_intervention_hours.blank? and scheduled_intervention_minutes.blank?
  end
  
  def validates_scheduled_delivery_subcontracting
    if scheduled_delivery_subcontracting?
      error_message = "ne doit pas être renseigné"
      errors.add(:scheduled_delivery_vehicle_ids,     error_message) unless scheduled_delivery_vehicles.empty?
      errors.add(:scheduled_delivery_vehicles_rental, error_message) unless scheduled_delivery_vehicles_rental.blank?
      errors.add(:scheduled_deliverer_ids,            error_message) unless scheduled_deliverers.empty?
    else
      error_message = I18n.t 'activerecord.errors.messages.blank'
      errors.add(:scheduled_deliverer_ids,            error_message) if scheduled_deliverers.empty?
      errors.add(:scheduled_delivery_vehicle_ids,     error_message) if scheduled_delivery_vehicles.empty?
    end
  end
  
  def validates_scheduled_installation_subcontracting
    if scheduled_installation_subcontracting?
      error_message = "ne doit pas être renseigné"
      errors.add(:scheduled_installation_equipment_ids,     error_message) unless scheduled_installation_equipments.empty?
      errors.add(:scheduled_installation_equipments_rental, error_message) unless scheduled_installation_equipments_rental.blank?
      errors.add(:scheduled_installer_ids,                  error_message) unless scheduled_installers.empty?
    else
      error_message = I18n.t 'activerecord.errors.messages.blank'
      errors.add(:scheduled_installer_ids,                  error_message) if scheduled_installers.empty?
      #errors.add(:scheduled_installation_equipment_ids,     error_message) if scheduled_installation_equipments.empty?
    end
  end
  
  def validates_intervention_duration
    errors.add(:intervention_hours, "La durée de l'intervention est requise") if intervention_hours.blank? and intervention_minutes.blank?
  end
  
  def validates_delivery_subcontracting
    if delivery_subcontracting?
      error_message = "ne doit pas être renseigné"
      errors.add(:delivery_vehicle_ids,     error_message) unless delivery_vehicles.empty?
      errors.add(:delivery_vehicles_rental, error_message) unless delivery_vehicles_rental.blank?
      errors.add(:deliverer_ids,            error_message) unless deliverers.empty?
    else
      error_message = I18n.t 'activerecord.errors.messages.blank'
      errors.add(:deliverer_ids,            error_message) if deliverers.empty?
      errors.add(:delivery_vehicle_ids,     error_message) if delivery_vehicles.empty?
    end
  end
  
  def validates_installation_subcontracting
    if installation_subcontracting?
      error_message = "ne doit pas être renseigné"
      errors.add(:installation_equipment_ids,     error_message) unless installation_equipments.empty?
      errors.add(:installation_equipments_rental, error_message) unless installation_equipments_rental.blank?
      errors.add(:installer_ids,                  error_message) unless installers.empty?
    else
      error_message = I18n.t 'activerecord.errors.messages.blank'
      errors.add(:installer_ids,                  error_message) if installers.empty?
    end
  end
  
  def validates_emptiness_of_all_fields
    error_message = "ne doit pas être renseigné"
    
    errors.add(:delivery_at,          error_message) unless delivery_at.nil?
    errors.add(:intervention_hours,   error_message) unless delivery_at.blank?
    errors.add(:intervention_minutes, error_message) unless delivery_at.blank?
    errors.add(:internal_actor_id,    error_message) unless delivery_at.nil?
    
    errors.add(:delivery_vehicle_ids,     error_message) unless delivery_vehicles.empty?
    errors.add(:delivery_vehicles_rental, error_message) unless delivery_vehicles_rental.blank?
    errors.add(:deliverer_ids,            error_message) unless deliverers.empty?
    
    errors.add(:installation_equipment_ids,     error_message) unless installation_equipments.empty?
    errors.add(:installation_equipments_rental, error_message) unless installation_equipments_rental.blank?
    errors.add(:installer_ids,                  error_message) unless installers.empty?
  end
  
  def validates_emptiness_of_comments_and_delivered
    error_message = "ne doit pas être renseigné"
    
    errors.add(:comments, error_message)  unless comments.blank?
    errors.add(:delivered, error_message) unless delivered.nil?
  end
  
  def validates_emptiness_of_postponed
    errors.add(:postponed, "ne doit pas être renseigné") unless postponed.nil?
  end

  def scheduled_delivery_subcontracting?
    scheduled_delivery_subcontractor_id
  end
  
  def delivery_subcontracting?
    delivery_subcontractor_id
  end
  
  def scheduled_installation_subcontracting?
    scheduled_installation_subcontractor_id
  end
  
  def installation_subcontracting?
    installation_subcontractor_id
  end
  
  def delivery?
    delivery_note.delivery?
  end
  
  def installation?
    delivery_note.installation?
  end
  
  def status
    if delivered.nil?
      if postponed
        STATUS_POSTPONED
      else
        STATUS_SCHEDULED
      end
    elsif delivered == true
      STATUS_DELIVERED
    else
      STATUS_UNDELIVERED
    end
  end
  
  def status_was
    if delivered_was.nil?
      if postponed_was
        STATUS_POSTPONED
      else
        STATUS_SCHEDULED
      end
    elsif delivered_was == true
      STATUS_DELIVERED
    else
      STATUS_UNDELIVERED
    end
  end
  
  def scheduled?
    status == STATUS_SCHEDULED
  end
  
  def delivered?
    status == STATUS_DELIVERED
  end
  
  def undelivered?
    status == STATUS_UNDELIVERED
  end
  
  def postponed?
    status == STATUS_POSTPONED
  end
  
  def realized?
    delivered? or undelivered?
  end
  
  def was_scheduled?
    status_was == STATUS_SCHEDULED
  end
  
  def was_delivered?
    status_was == STATUS_DELIVERED
  end
  
  def was_undelivered?
    status_was == STATUS_UNDELIVERED
  end
  
  def was_postponed?
    status_was == STATUS_POSTPONED
  end
  
  def was_realized?
    was_delivered? or was_undelivered?
  end
  
  def outdated?
    return false if new_record? or scheduled_delivery_at.nil?
    scheduled_delivery_at.to_date.past?
  end
  
  def scheduled_intervention_duration
    duration = scheduled_intervention_hours.blank? ? '' : "#{scheduled_intervention_hours}h"
    duration += scheduled_intervention_minutes.blank? ? '' : "#{scheduled_intervention_minutes.to_s.rjust(2, '0')}min"
  end
  
  def intervention_duration
    duration = intervention_hours.blank? ? '' : "#{intervention_hours}h"
    duration += intervention_minutes.blank? ? '' : "#{intervention_minutes.to_s.rjust(2, '0')}min"
  end
  
  def discard_attributes=(discard_attributes)
    discard_attributes.each do |attributes|
      if attributes[:id].blank?
        discards.build(attributes) unless attributes[:quantity].blank? or attributes[:quantity].to_i.zero?
      else
        discard = discards.detect { |d| d.id == attributes[:id].to_i }
        discard.attributes = attributes
      end
    end
  end

  def save_discards
    discards.each do |d|
      if d.quantity
        d.save(false)
      else
        d.destroy
      end
    end
  end
  
  def delivery_note_sign_attributes=(attributes)
    if !attributes[:signed_on].blank? || !attributes[:attachment].blank?
      delivery_note.attributes = attributes
      delivery_note.status = DeliveryNote::STATUS_SIGNED
    end
  end
  
  def sign_delivery_note
    if delivery_note
      delivery_note.save(false) if delivery_note.changes.include?("status")
    end
  end
end
