require File.dirname(__FILE__) + '/../logistics_test'

class InventoryTest < ActiveSupport::TestCase
  #TODO
  #has_permissions :as_business_object
  
  should_have_many :stock_flows
  should_have_many :stock_inputs
  should_have_many :stock_outputs
  
  should_validate_presence_of :supply_class
  
  #TODO
  #validates_stock_flows_uniqueness_of_supply
  #validates_stock_flows_supply_type
  #
  #stock_flow_attributes
  #save_stock_flows
end
