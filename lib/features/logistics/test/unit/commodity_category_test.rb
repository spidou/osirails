require File.dirname(__FILE__) + '/../logistics_test'

class CommodityCategoryTest < ActiveSupport::TestCase
  #TODO
  #has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  #has_reference   :prefix => :logistics
  
  should_have_many :sub_categories
  
  context "A commodity_category" do
    setup do
      @supply_category = CommodityCategory.new
    end
    teardown do
      @supply_category = nil
    end
    
    subject{ @supply_category }
    
    include SupplyCategoryTest::OnlyFirstLevelCategoriesMethods
    include SupplyCategoryTest::CommonMethods
  end
end
