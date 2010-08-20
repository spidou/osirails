require File.dirname(__FILE__) + '/../logistics_test'

class ConsumableSubCategoryTest < ActiveSupport::TestCase
  should_belong_to :supply_category
  
  context "A consumable_sub_category" do
    setup do
      @supply_sub_category = ConsumableSubCategory.new
      @supply_category_type = ConsumableCategory
    end
    teardown do
      @supply_sub_category = nil
    end
    
    subject{ @supply_sub_category }
    
    include SupplySubCategoryTest
  end
  
  context "A consumable_sub_category" do
    setup do
      @supply_category = ConsumableSubCategory.new
    end
    teardown do
      @supply_category = nil
    end
    
    subject{ @supply_category }
    
    include SupplyCategoryTest::CommonMethods
  end
end
