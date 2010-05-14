require 'test/test_helper'
require File.dirname(__FILE__) + '/../logistics_test'

class CommoditySubCategoryTest < ActiveSupport::TestCase
  
  should_belong_to :supply_category
  
  context "A commodity_sub_category" do
    setup do
      @supply_sub_category = CommoditySubCategory.new
      @supply_category_type = CommodityCategory
    end
    teardown do
      @supply_sub_category = nil
    end
    
    subject{ @supply_sub_category }
    
    include SupplySubCategoryTest
  end
  
  context "A commodity_sub_category" do
    setup do
      @supply_category = CommoditySubCategory.new
    end
    teardown do
      @supply_category = nil
    end
    
    subject{ @supply_category }
    
    include SupplyCategoryTest::CommonMethods
  end
  
end
