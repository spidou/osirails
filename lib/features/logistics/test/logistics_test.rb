require File.dirname(__FILE__) + '/unit/supply_test'
require File.dirname(__FILE__) + '/unit/supply_category_test'
require File.dirname(__FILE__) + '/unit/supply_sub_category_test'
require File.dirname(__FILE__) + '/unit/stock_flow_test'

class Test::Unit::TestCase
  
  def create_supply_with_stock_input_for(supply_sub_category)
    supply = supply_sub_category.supplies.build(:name => "Supply")
    supply.save!
    
    create_stock_input_for_supply(supply, :sleep_delay => true)
    
    return supply
  end
  
  def create_stock_input_for_supply(supply, args = {})
    default_values = {  :unit_price   => 100,
                        :quantity     => 100,
                        :created_at   => Time.zone.now,
                        :sleep_delay  => false }
    args = default_values.merge(args)
    
    stock_input = supply.stock_inputs.build :identifier => "123456789",
                                            :unit_price => args[:unit_price],
                                            :quantity   => args[:quantity],
                                            :created_at => args[:created_at]
    stock_input.save!
    sleep(1) if args[:sleep_delay] # to be sure that the stock_input is in the past compared with following assertions
    return stock_input
  end
  
  def create_stock_output_for_supply(supply, args = {})
    default_values = { :created_at  => Time.zone.now,
                       :sleep_delay => false }
    args = default_values.merge(args)  
    
    stock_output = supply.stock_outputs.build :identifier => "123456789",
                                              :quantity   => args[:quantity],
                                              :created_at => args[:created_at]
    stock_output.save!
    sleep(1) if args[:sleep_delay] # to be sure that the stock_output is in the past compared with following assertions
    return stock_output
  end
  
  def create_stock_output_to_set_stock_quantity_at_zero_for_supply(supply)
    flunk "supply should have a stock_quantity > 0" if supply.stock_quantity.zero?
    return create_stock_output_for_supply(supply, :quantity => supply.stock_quantity, :sleep_delay => true)
  end
  
  def disable_supply(supply)
    # create a stock_output to set the stock_quantity at 0 (to authorize the deactivation of the supply)
    if supply.stock_quantity > 0
      create_stock_output_to_set_stock_quantity_at_zero_for_supply(supply)
    end
    flunk "supply should be able to be disabled (stock_quantity = #{supply.stock_quantity}, stock_value = #{supply.stock_value})" unless supply.can_be_disabled?
    
    supply.disable
    flunk "supply should be disabled" if supply.enabled_was
  end
  
  def build_inventory_with(supplies_quantities = {}, datetime = Time.zone.now)
    supplies = supplies_quantities.keys
    
    supply_types = supplies.collect{ |s| s.class.name }.uniq
    flunk "all supplies should be of the same type\nbut was #{supply_types.inspect}" if supply_types.size > 1
    inventory = Inventory.new(:supply_type => supply_types.first, :created_at => datetime)
    
    attributes = []
    supplies_quantities.each do |supply, new_quantity|
      # this IF block is a repetition of what we can find in Inventory#stock_flow_attributes= but we have to generate manually stock_flows in order to give created_at value
      if new_quantity > supply.stock_quantity
        inventory.stock_inputs.build(:from_inventory => true, :quantity => new_quantity - supply.stock_quantity, :supply_id => supply.id, :created_at => datetime)
      elsif new_quantity < supply.stock_quantity
        inventory.stock_outputs.build(:from_inventory => true, :quantity => supply.stock_quantity - new_quantity, :supply_id => supply.id, :created_at => datetime)
      end
    end
    
    return inventory
  end
  
  def create_inventory_with(supplies_quantities = {}, datetime = Time.zone.now)
    inventory = build_inventory_with(supplies_quantities, datetime)
    inventory.save!
    inventory.reload
  end
  
end
