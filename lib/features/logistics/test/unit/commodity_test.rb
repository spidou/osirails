require 'test/test_helper'
require File.dirname(__FILE__) + '/../logistics_test'

class CommodityTest < ActiveSupport::TestCase
  
  #TODO
  #has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  #has_reference   :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  should_belong_to :supply_sub_category
  
  context "A commodity" do
    setup do
      @supply = Commodity.new
      @supply_sub_category_type = CommoditySubCategory
    end
    teardown do
      @supply = nil
    end
    
    subject{ @supply }
    
    include SupplyTest
  end
  
end
