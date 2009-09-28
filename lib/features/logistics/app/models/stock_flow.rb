class StockFlow < ActiveRecord::Base
  # Relationships
  belongs_to :supply
  belongs_to :supplier

  # Validates
  validates_presence_of :supply_id
  validates_presence_of :supply, :if => :supply_id
  validates_presence_of :supplier_id
  validates_presence_of :supplier, :if => :supplier_id
  validates_presence_of :supplier_supply
  validates_numericality_of :quantity, :greater_than => 0
  validate :validates_enabled_supply 
  
  def validates_enabled_supply
    unless supply.nil?
      errors.add(:supply, "est désactivé") unless self.supply.enable
    end
  end
  
  # For will_paginate
  STOCK_FLOWS_PER_PAGE = 15 

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supply] = "Fourniture :"
  @@form_labels[:supplier] = "Fournisseur :"
  @@form_labels[:quantity] = "Quantité :"
  
  # This method fills required attributes before create the stock flow
  def before_create
    date = self.created_at.nil? ? Date.today : self.created_at.to_date
    self.previous_stock_quantity = self.supplier_supply.stock_quantity(date)
    self.previous_stock_value = self.supplier_supply.stock_value(date)
    
    if self.class.name == "StockOutput"
      self.fob_unit_price = self.supplier_supply.average_unit_price(date)
      self.tax_coefficient = 0
    end
  end

  # This method prevent the modification of the stock flow, update is forgiven
  def before_update
    return false
  end  
  
  # This method calculate the stock flow unit price according to its 
  # fob unit price and tax coefficient
  def unit_price
    (self.fob_unit_price * (1+(self.tax_coefficient/100))) unless (self.fob_unit_price.nil? or self.tax_coefficient.nil?)
  end
  
  # This method return the supplier supply according to its supply and supplier
  def supplier_supply
    unless self.supply_id.nil? or self.supplier_id.nil?
      SupplierSupply.find_by_supply_id_and_supplier_id(self.supply_id, self.supplier_id)
    end
  end
end
