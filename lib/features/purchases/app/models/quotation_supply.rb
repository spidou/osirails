class QuotationSupply < ActiveRecord::Base
  include ProductBase
  include PurchasesSuppliesBase
  
  has_permissions :as_business_object
  
  has_many :quotation_purchase_request_supplies
  has_many :purchase_request_supplies, :through => :quotation_purchase_request_supplies
  
  belongs_to :quotation
  belongs_to :supply
  
  attr_accessor :purchase_request_supplies_ids, :purchase_request_supplies_deselected_ids, :should_destroy
  
#  validates_persistence_of :position, :if => :quotation_locked?
  
  validates_presence_of :position
  validates_presence_of :designation, :if => :free_supply?
  
  validates_numericality_of :quantity, :unit_price, :greater_than => 0
  validates_numericality_of :taxes, :greater_than_or_equal_to => 0
  
  before_destroy :can_be_destroyed?
  
  def can_be_destroyed?
    !new_record? and quotation and quotation.was_drafted?
  end
  
  def can_be_edited?
    !new_record? and quotation and quotation.was_drafted?
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

#  #TODO test this method    
#  def quotation_locked?
#    quotation and (quotation.signed? or quotation.sent_to_supplier?)
#  end
end
