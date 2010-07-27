require File.dirname(__FILE__) + '/../logistics_test'

class ConsumableTest < ActiveSupport::TestCase
  #TODO
  #has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  #has_reference   :symbols => [ :supply_sub_category ], :prefix => :logistics
  
  should_belong_to :supply_sub_category
  
  context "A consumable" do
    setup do
      @supply = Consumable.new
      @supply_sub_category_type = ConsumableSubCategory
    end
    teardown do
      @supply = nil
    end
    
    subject{ @supply }
    
    include SupplyTest
  end
end
