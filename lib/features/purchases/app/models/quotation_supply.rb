class QuotationSupply < ActiveRecord::Base
  include ProductBase
  
  has_permissions :as_business_object
  
  has_many :quotation_purchase_request_supplies
  has_many :purchase_request_supplies, :through => :quotation_purchase_request_supplies
  
  belongs_to :quotation
  belongs_to :supply
  
  attr_accessor :purchase_supplies_ids
  attr_accessor :should_destroy
  
  validates_presence_of :designation, :if => :free_supply?
  validates_presence_of :supplier_designation
  
  validates_numericality_of :quantity, :unit_price, :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_destroyed?
    !new_record? and quotation and quotation.was_drafted?
  end
  
  def can_be_edited?
    !new_record? and quotation and quotation.was_drafted?
  end
  
  def supplier_supply(supplier_id = nil, supply_id = nil)
    supplier_id ||= quotation.supplier_id if quotation
    supply_id   ||= supply.id if supply
    SupplierSupply.find_by_supplier_id_and_supply_id(supplier_id, supply_id)
  end

  def taxes # for compatibility with product_base.rb
    self[:taxes]
  end
  
  def vat=(vat) # for compatibility with product_base.rb
    self.taxes = vat
  end

  alias_method :vat, :taxes # for compatibility with product_base.rb

  def existing_supply?
    !supply_id.nil?
  end
  
  def free_supply?
    !existing_supply?
  end
end
