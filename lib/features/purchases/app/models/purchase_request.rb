class PurchaseRequest < ActiveRecord::Base
  
  has_reference :prefix => :purchases
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  #relationships
  has_many :purchase_request_supplies
  belongs_to :canceller, :class_name => "User", :foreign_key => 'cancelled_by'
  belongs_to :user
  belongs_to :employee
  belongs_to :service
  
  #form_for
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:service]                = "Service concerné :"
  @@form_labels[:employee]               = "Demandeur :"
  @@form_labels[:user]                   = "Créateur de la demande :"
  @@form_labels[:reference]              = "Référence :"
  @@form_labels[:statut]                 = "Status :"
    
  # for pagination : number of instances by index page
  REQUESTS_PER_PAGE = 15
  
  #validations
  validates_presence_of :user_id, :employee_id, :service_id, :reference
  validates_length_of :purchase_request_supplies, :minimum => 1, :message => "Veuillez selectionner au moins une matiere premiere ou un consommable"
  validates_associated  :purchase_request_supplies
  
  validates_presence_of :cancelled_by, :cancelled_comment, :if => :cancelled_at
  
  #callbacks
  before_validation_on_create :update_reference
  after_save  :save_purchase_request_supplies
  
  
  #method
  
  def cancelled?
    self.cancelled_at ? true : false
  end
  
  def save_purchase_request_supplies
    purchase_request_supplies.each do |e|
        e.save(false)
    end
  end
  
  def purchase_request_supply_attributes=(purchase_request_supply_attributes)
    purchase_request_supply_attributes.each do |attributes|
      if attributes[id].blank?
        purchase_request_supplies.build(attributes)
      else
        purchase_request_supply = purchase_request_supplies.detect { |t| t.id == attributes[:id].to_i }
        purchase_request_supply.attributes = attributes
      end
    end
  end
  
  #a modifier
  def untreated_purchase_request_supplies
    tab_of_request_supplies = []
    self.purchase_request_supplies.each do |purchase_request_supply|
      tab_of_request_supplies <<  purchase_request_supply if purchase_request_supply.untreated?
    end
    tab_of_request_supplies
  end
  
  def during_treatment_purchase_request_supplies
    tab_of_request_supplies = []
    self.purchase_request_supplies.each do |purchase_request_supply|
      tab_of_request_supplies <<  purchase_request_supply if purchase_request_supply.during_treatment?
    end
    tab_of_request_supplies
  end
  
  def treated_purchase_request_supplies
    tab_of_request_supplies = []
    self.purchase_request_supplies.each do |purchase_request_supply|
      tab_of_request_supplies <<  purchase_request_supply if purchase_request_supply.treated?
    end
    tab_of_request_supplies
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
end
