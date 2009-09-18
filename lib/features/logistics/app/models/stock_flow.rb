class StockFlow < ActiveRecord::Base
  belongs_to :supply
  belongs_to :supplier

  validates_presence_of :supply_id, :supplier_id
  validates_presence_of :supply, :if => :supply_id
  validates_presence_of :supplier, :if => :supplier_id
  validates_presence_of :supplier_supply
  validates_numericality_of :quantity, :greater_than => 0

  def before_create
    date = self.created_at.nil? ? Date.today : self.created_at.to_date
    self.previous_stock_quantity = self.supplier_supply.stock_quantity(date)
    self.previous_stock_value = self.supplier_supply.stock_value(date)
    
    if self.class.name == "StockOutput"
      self.fob_unit_price = self.supplier_supply.average_unit_price(date)
      self.tax_coefficient = 0
    end
  end

  def before_update
    return false
  end  
  
  def unit_price
    (self.fob_unit_price * (1+(self.tax_coefficient/100))) unless (self.fob_unit_price.nil? or self.tax_coefficient.nil?)
  end

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supply] = "Fourniture :"
  @@form_labels[:supplier] = "Fournisseur :"
  @@form_labels[:quantity] = "Quantité :"

  def supplier_supply
    unless self.supply_id.nil? or self.supplier_id.nil?
      SupplierSupply.find_by_supply_id_and_supplier_id(self.supply_id, self.supplier_id)
    end
  end

end

