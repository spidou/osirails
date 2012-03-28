require 'test/test_helper'

require File.dirname(__FILE__) + '/unit/supply_test'
require File.dirname(__FILE__) + '/unit/supply_category_test'
require File.dirname(__FILE__) + '/unit/supply_sub_category_test'
require File.dirname(__FILE__) + '/unit/supply_type_test'
require File.dirname(__FILE__) + '/unit/stock_flow_test'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
  
  def create_default_supply(attributes = {})
    supply_type = SupplyType.find_by_id(attributes.delete(:supply_type_id)) || SupplyType.first
    create_supply_for(supply_type, attributes)
  end
  
  def create_supply_type_for(supply_sub_category)
    supply_type = supply_sub_category.supply_types.build(:name => "Supply Type #{(rand*1000.to_i)}")
    supply_type.save!
    return supply_type
  end
  
  def create_supply_for(supply_type, attributes = {})
    supply = supply_type.supplies.build(attributes)
    supply.measure ||= 1 if supply.unit_measure
    supply.measure = nil if supply.unit_measure.nil?
    supply.save!
    return supply
  end
  
  def create_supply_with_stock_input_for(supply_sub_category)
    supply_type = create_supply_type_for(supply_sub_category)
    
    supply = create_supply_for(supply_type, :measure => 5)
    supply.supplier_supply_attributes = [ { :supplier_id    => thirds(:first_supplier).id,
                                            :fob_unit_price => 100,
                                            :taxes          => 10 } ]
    supply.save!
    
    flunk "supply should have 1 supplier_supply" unless supply.supplier_supplies.count == 1
    
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
  
  def disable_supply_type(supply_type)
    #TODO perhaps we should disable all supplies of the supply_type before trying to disable it
    supply_type.disable
    flunk "supply_type should be disabled" if supply_type.enabled_was
  end
  
  def build_inventory_with(supplies_quantities = {}, datetime = Time.zone.now)
    supplies = supplies_quantities.keys
    
    supply_classes = supplies.collect{ |s| s.class.name }.uniq
    flunk "all supplies should be of the same type\nbut was #{supply_classess.inspect}" if supply_classes.many?
    inventory = Inventory.new(:supply_class => supply_classes.first, :created_at => datetime)
    
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
