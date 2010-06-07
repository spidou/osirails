class PurchaseRequest < ActiveRecord::Base
  
  #status
  STATUS_TRAITED = "traité"
  STATUS_DURING_TRAITMENT = "en cours de traitement"
  STATUS_UNTRAITED = "non traité"
  
  #relationships
  has_many :purchase_request_supplies
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
  
  # for pagination : number of instances by index page
  REQUESTS_PER_PAGE = 15
  
  #validations
  validates_presence_of :user_id, :employee_id, :service_id
  validates_associated  :purchase_request_supplies
  
  #callbacks
  
  after_save  :save_purchase_request_supplies
  
  
  #method
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
  
  def count_untraited_status
    purchase_request_supplies.reject(&:order_supply_id).size
  end
  
  def count_during_traitment_status
    counter = 0
    for supply in self.purchase_request_supplies
      counter += 1 if supply.order_supply_id and  supply.purchase_order_supply.purchase_order.status == PurchaseOrder::STATUS_DRAFT and supply.purchase_order_supply.purchase_order.cancelled_by == nil
    end
    counter
  end
  
  def count_traited_status
    counter = 0
    for supply in self.purchase_request_supplies
      counter += 1 if supply.purchase_order_supply_id and  supply.purchase_order_supply.purchase_order.status != PurchaseOrder::STATUS_DRAFT and supply.purchase_order_supply.purchase_order.cancelled_by == nil 
    end
    counter
  end
  
  def get_status_for_supply
    
  end
  
end
