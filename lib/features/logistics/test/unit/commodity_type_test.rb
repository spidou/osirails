require File.dirname(__FILE__) + '/../logistics_test'

class CommodityTypeTest < ActiveSupport::TestCase
  should_belong_to :supply_sub_category
  
  should_have_many :supplies
  
  #TODO write tests for the following :
  # has_reference :symbols => [ :supply_sub_category ], :prefix => :logistics
  #
  # has_search_index :only_attributes     => [ :reference, :name ],
  #                 :only_relationships  => [ :supply_sub_category ]
  
  context "A commodity_type" do
    setup do
      @supply_type = CommodityType.new
      @supply_sub_category_type = CommoditySubCategory
    end
    teardown do
      @supply_type = nil
    end
    
    subject{ @supply_type }
    
    include SupplyTypeTest
  end
  
  context "A commodity_type" do
    setup do
      @supply_category = CommodityType.new
    end
    teardown do
      @supply_category = nil
    end
    
    subject{ @supply_category }
    
    include SupplyCategoryTest::CommonMethods
  end
end
