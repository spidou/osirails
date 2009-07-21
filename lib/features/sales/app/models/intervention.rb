class Intervention < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :delivery_note
  
  has_many :deliverers_interventions
  has_many :deliverers, :through => :deliverers_interventions
  
  validates_presence_of :delivery_note, :scheduled_delivery_at
  
  validates_inclusion_of :on_site, :in => [true, false]
  
  #validates_associated :delivery_note
  
  def validate
    if on_site?
      errors.add(:deliverers, "est requis lorsque la livraison est sur site") if deliverers.empty?
    else
      errors.add(:deliverers, "est interdit lorsque la livraison n'est pas sur site") unless deliverers.empty?
    end
    
    unless new_record?
      errors.add(:delivered, "est requis") unless delivered == true or delivered == false
      errors.add(:comments, "est requis") if comments.blank? and delivered == false
    end
  end
  
  def on_site?
    on_site == true
  end
  
  def delivered?
    delivered == true
  end
  
end
