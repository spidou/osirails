class QuotationRequestSupply < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  has_many :quotation_request_purchase_request_supplies
  has_many :purchase_request_supplies, :through => :quotation_request_purchase_request_supplies
  
  belongs_to :quotation_request
  belongs_to :supply
  
  attr_accessor :purchase_request_supplies_ids, :purchase_request_supplies_deselected_ids, :should_destroy
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]        = "Titre :"
  @@form_labels[:description] = "Description :"
  
  validates_presence_of :position
  validates_presence_of :supply, :if => :supply_id
  
  with_options :if => :comment_line? do |qr|
    qr.validates_presence_of :name, :description
  end
  
  with_options :unless => :comment_line? do |qr|
    qr.validates_presence_of :designation
    qr.validates_numericality_of :quantity, :greater_than => 0
  end
  
  before_destroy :can_be_destroyed?
  
  #TODO test this method
  def position
    self[:position] ||= 0
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_destroyed?
    !new_record? && quotation_request(true).was_drafted?
  end
  
  def existing_supply?
    supply ? true : false
  end
  
  def free_supply?
    !existing_supply? and !comment_line
  end
  
  def comment_line?
    existing_supply? ? false : comment_line
  end
  
  def supplier_supply
    supply_id and quotation_request and quotation_request.supplier_id ? SupplierSupply.find_by_supply_id_and_supplier_id(supply_id, quotation_request.supplier_id) : nil
  end
  
  def designation
    existing_supply? ? self[:designation] ||= supply.designation : self[:designation]
  end
  
  def supplier_reference
    supplier_supply ? (self[:supplier_reference] ||= supplier_supply.supplier_reference) : self[:supplier_reference]
  end
  
  def supplier_designation
    supplier_supply ? (self[:supplier_designation] ||= supplier_supply.supplier_designation) : self[:supplier_designation]
  end
  
  #TODO test this 
  def can_add_purchase_request_supply_id?(id)
    purchase_request_supplies_deselected_ids && purchase_request_supplies_deselected_ids.split(';').detect{ |deselected_id| deselected_id.to_i == id.to_i } ? false : true
  end
  
  #TODO test this method
  def not_cancelled_purchase_request_supplies
    PurchaseRequestSupply.all(:include => :purchase_request, :conditions => ['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL', supply_id])
  end
  
  #TODO test this method
  def unconfirmed_purchase_request_supplies
    not_cancelled_purchase_request_supplies.select{ |prs| (new_record? and !prs.confirmed_purchase_order_supply) or (!new_record? and (self.purchase_request_supplies.detect{|t| t.id == prs.id} || !prs.confirmed_purchase_order_supply) ) }
  end
  
  #TODO test this method
  def get_purchase_request_supplies_ids
    res = []
    unconfirmed_purchase_request_supplies.each do |prs|
      if quotation_request_purchase_request_supplies.detect{ |t| t.purchase_request_supply_id == prs.id } and can_add_purchase_request_supply_id?(prs.id)
        res << prs.id
      end
    end
    res.join(";")
  end
  
  #TODO test this method
  def already_associated_with_purchase_request_supply?(purchase_request_supply)
    quotation_request_purchase_request_supplies.detect{ |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } && can_add_purchase_request_supply_id?(purchase_request_supply.id) 
  end
end
