class SupplierSupply < ActiveRecord::Base
  has_permissions :as_business_object

  # Relationships
  belongs_to :supply
  belongs_to :supplier

  validates_uniqueness_of :supplier_id, :scope => :supply_id
  validates_presence_of :supplier_id, :reference, :name
  validates_numericality_of :lead_time, :fob_unit_price, :tax_coefficient, :greater_than_or_equal_to => 0
  
  attr_accessor :should_destroy
  attr_accessor :should_update

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:supplier] = "Fournisseur :"
  @@form_labels[:reference] = "Référence :"
  @@form_labels[:name] = "Désignation :"
  @@form_labels[:fob_unit_price] = "FOB de base :"
  @@form_labels[:tax_coefficient] = "Coefficient de taxe :"
  @@form_labels[:lead_time] = "Délai d'approvisionnement :"
  
  # This method prevent the removal if it's already been used
  def before_destroy
    return false if self.has_been_used?
  end
  
  # This method permit to determine if the supply has already been
  # treated by a stock flow
  def has_been_used?
    true if StockFlow.find_by_supply_id_and_supplier_id(self.supply_id,self.supplier_id)
  end

  # This method> return all the linked stock flows
  def stock_flows
     StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ?", self.supply_id, self.supplier_id])
  end
  
  def previous_stock_quantity(date=Date.today)
    stock_flows = StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ? AND created_at < ?", self.supply_id, self.supplier_id, date+1], :order => "YEAR(created_at) DESC, MONTH(created_at) DESC, DAY(created_at) DESC, HOUR(created_at) ASC, MINUTE(created_at) ASC, SECOND(created_at)", :limit => 1)
    stock_flow = stock_flows.first unless stock_flows.empty?
    stock_flows.empty? ? 0.0 : stock_flow.previous_stock_quantity
  end
  
  def previous_stock_value(date=Date.today)23
  
    stock_flows = StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ? AND created_at < ?", self.supply_id, self.supplier_id, date+1], :order => "YEAR(created_at) DESC, MONTH(created_at) DESC, DAY(created_at) DESC, HOUR(created_at) ASC, MINUTE(created_at) ASC, SECOND(created_at)", :limit => 1)
    stock_flow = stock_flows.first unless stock_flows.empty?
    stock_flows.empty? ? 0.0 : stock_flow.previous_stock_value
  end
  
  def stock_quantity(date=Date.today)
    stock_flows = StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ? AND created_at < ?", self.supply_id, self.supplier_id, date+1], :order => "created_at DESC", :limit => 1)
    stock_flow = stock_flows.first unless stock_flows.empty?
    stock_flows.empty? ? 0.0 : (stock_flow.previous_stock_quantity + (stock_flow.class.name == "StockInput" ? stock_flow.quantity : -(stock_flow.quantity)))
  end
  
  def stock_value(date=Date.today)
    stock_flows = StockFlow.find(:all, :conditions => ["supply_id = ? AND supplier_id = ? AND created_at < ?", self.supply_id, self.supplier_id, date+1], :order => "created_at DESC", :limit => 1)
    stock_flow = stock_flows.first unless stock_flows.empty?
    stock_flows.empty? ? 0.0 : (stock_flow.previous_stock_value.round + (self.supply.measure * stock_flow.quantity * (stock_flow.class.name == "StockInput" ? stock_flow.unit_price : -(stock_flow.unit_price)))).round(7)
  end

  def average_unit_price(date=Date.today)
    if [0,nil].include?(self.stock_quantity(date))
      0.0
    else
      self.stock_value(date).round/(self.stock_quantity(date)*self.supply.measure)
    end
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end

  def should_update?
    should_update.to_i == 1
  end
end

