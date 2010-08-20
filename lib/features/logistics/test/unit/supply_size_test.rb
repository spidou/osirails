require File.dirname(__FILE__) + '/../logistics_test'

class SupplySizeTest < ActiveSupport::TestCase
  #TODO
  # has_permissions :as_business_object
  
  should_have_many :supply_sizes_unit_measures
  should_have_many :unit_measures, :through => :supply_sizes_unit_measures
  
  should_validate_presence_of :name
  
  should_validate_uniqueness_of :name
  
  context "A supply size" do
    setup do
      @supply_size = SupplySize.new(:name => "Diameter")
    end
    
    context "with a short_name" do
      setup do
        @supply_size.short_name = "D"
      end
      
      should "have a valid 'name_and_short_name'" do
        assert_equal "Diameter (D)", @supply_size.name_and_short_name
      end
    end
    
    context "without short_name" do
      should "have a valid 'name_and_short_name'" do
        assert_equal "Diameter", @supply_size.name_and_short_name
      end
    end
  end
end
