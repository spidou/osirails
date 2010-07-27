class StockFlow < ActiveRecord::Base
  belongs_to :supply
  belongs_to :inventory
  
  named_scope :of_commodities, :include => [:supply], :conditions => ["supplies.type = ?", 'Commodity'],  :order => "stock_flows.created_at DESC"
  named_scope :of_consumables, :include => [:supply], :conditions => ["supplies.type = ?", 'Consumable'], :order => "stock_flows.created_at DESC"
  
  named_scope :from_inventories, :conditions => ["inventory_id IS NOT NULL"]
  
  validates_presence_of :supply_id
  validates_presence_of :supply, :if => :supply_id

  validates_presence_of :identifier, :unless => :from_inventory?
  
  validates_numericality_of :quantity, :greater_than => 0
  
  validates_numericality_of :unit_price, :previous_stock_value, :previous_stock_quantity, :greater_or_equal_than => 0, :if => :supply
  
  validates_persistence_of :supply_id, :identifier, :unit_price, :quantity, :previous_stock_value, :previous_stock_quantity
  
  validate :validates_enabled_supply
  
  before_validation_on_create :set_up_previous_stock_value_and_quantity, :set_up_default_unit_price
  
  before_update   :can_be_edited? #OPTIMIZE can't we remove that callback? this seems to be a repetition of validates_persistence_of (be careful because validation can be skipped, unlike before_update)
  before_destroy  :can_be_destroyed?
  
  # For will_paginate
  STOCK_FLOWS_PER_PAGE = 15
  
  attr_accessor :from_inventory
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supply]    = "Fourniture :"
  @@form_labels[:quantity]  = "Quantité :"
  
  def validates_enabled_supply
    errors.add(:supply, "est désactivé") if supply and !supply.enabled?
  end

  def from_inventory?
    inventory_id or from_inventory
  end
  
  # This method fills required attributes before create the stock flow
  def set_up_previous_stock_value_and_quantity
    return unless supply
    self.previous_stock_quantity  = supply.stock_quantity
    self.previous_stock_value     = supply.stock_value
  end
  
  def set_up_default_unit_price
    raise "StockFlow doesn't implement 'set_up_default_unit_price'. A subclass may override this method"
  end
  
  def can_be_edited?
    false
  end
  
  def can_be_destroyed?
    false
  end

  def calculation_method
    raise "StockFlow doesn't implement 'calculation_method'. A subclass may override this method"
  end
  
  def current_stock_value
    @current_stock_value ||= current_stock_quantity.zero? ? 0.0 : previous_stock_value.send(calculation_method, unit_price * quantity)
  end
  
  def current_stock_quantity
    @current_stock_quantity ||= previous_stock_quantity.send(calculation_method, quantity)
  end
end
