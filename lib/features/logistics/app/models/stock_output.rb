class StockOutput < StockFlow
  has_permissions :as_business_object
  
  named_scope :commodities_stock_outputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Commodity.find(:all)]
  named_scope :consumables_stock_outputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Consumable.find(:all)]
  
  @@form_labels[:file_number] = "Numéro de dossier :"
  
  validates_presence_of :file_number, :unless => :adjustment
  validate :validates_stock_availability

  def validates_stock_availability
    unless self.supplier_supply.nil? or self.quantity.nil?
      errors.add(:quantity, "(#{self.quantity}) est supérieur au stock disponible (#{self.supplier_supply.stock_quantity} pour le fournisseur #{self.supplier_supply.supplier.name})") if self.supplier_supply.stock_quantity < self.quantity
    end
  end
end

