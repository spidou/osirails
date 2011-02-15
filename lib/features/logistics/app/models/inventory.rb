class Inventory < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :stock_flows, :dependent => :nullify
  has_many :stock_inputs
  has_many :stock_outputs
  
  validates_presence_of :supply_type
  
  validates_associated :stock_inputs, :stock_outputs
  
  validate :validates_stock_flows_uniqueness_of_supply
  validate :validates_stock_flows_supply_type
  
  after_save :save_stock_flows
  
  INVENTORIES_PER_PAGE = 15
  
  def validates_stock_flows_uniqueness_of_supply
    supply_ids = stock_flows.collect(&:supply_id)
    errors.add(:stock_flows, "L'inventaire fait 2 fois référence au même article") if supply_ids.size != supply_ids.uniq.size
  end
  
  def validates_stock_flows_supply_type
    return unless supply_type
    
    supply_types = stock_flows.collect(&:supply).collect(&:type)
    errors.add(:stock_flows, "L'inventaire faire référence à des articles de types différents") if supply_types.uniq.many?
    errors.add(:stock_flows, "L'inventaire doit faire référence à des articles du type #{supply_type}") if supply_types.any? and supply_types.first != supply_type
  end
  
  def date
    @date ||= created_at
  end
  
  def stock_flow_attributes=(stock_flow_attributes)
    stock_flow_attributes.each do |attributes|
      supply_id = attributes.first.to_i
      new_quantity = attributes.last[:new_quantity]
      
      if new_quantity.to_s == new_quantity.to_i.to_s # if new_quantity is a number
        new_quantity = new_quantity.to_i
        supply = Supply.find(supply_id)
        if new_quantity > supply.stock_quantity
          stock_inputs.build(:from_inventory => true, :quantity => new_quantity - supply.stock_quantity, :supply_id => supply_id)
        elsif new_quantity < supply.stock_quantity
          stock_outputs.build(:from_inventory => true, :quantity => supply.stock_quantity - new_quantity, :supply_id => supply_id)
        end
      end
    end
  end
  
  def save_stock_flows
    stock_flows.each do |s|
      s.save(false)
    end
  end
end
