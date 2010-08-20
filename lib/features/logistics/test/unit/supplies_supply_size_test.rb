require File.dirname(__FILE__) + '/../logistics_test'

class SuppliesSupplySizeTest < ActiveSupport::TestCase
  #TODO test set_default_unit_measure
  
  should_belong_to :supply, :supply_size, :unit_measure
  
  should_validate_presence_of :supply_size, :unit_measure, :with_foreign_key => :default
  
  context "A supplies_supply_size" do
    setup do
      @supplies_supply_size = SuppliesSupplySize.new
    end
    
    should "NOT accept string in its value" do
      assert !@supplies_supply_size.accept_string?
    end
    
    context "with a value at nil" do
      setup do
        @supplies_supply_size.value = nil
      end
      
      should "be marked for destroy" do
        assert @supplies_supply_size.should_destroy?
      end
    end
    
    context "with a blank value" do
      setup do
        @supplies_supply_size.value = ""
      end
      
      should "be marked for destroy" do
        assert @supplies_supply_size.should_destroy?
      end
    end
    
    context "with a float value" do
      setup do
        @supplies_supply_size.value = 10.10
      end
      
      should "return a float value" do
        assert_equal Float, @supplies_supply_size.value.class
      end
    end
    
    context "with an integer value" do
      setup do
        @supplies_supply_size.value = 10
      end
      
      should "return a integer value" do
        assert_equal Fixnum, @supplies_supply_size.value.class
      end
    end
    
    context "belonging to a supply_size which accept string" do
      setup do
        @supplies_supply_size.supply_size = supply_sizes(:accept_string)
      end
      
      should "accept string in its value" do
        assert @supplies_supply_size.accept_string?
      end
    end
    
    context "belonging to a supply_size which NOT accept string" do
      setup do
        @supplies_supply_size.supply_size = supply_sizes(:not_accept_string)
      end
      
      should "NOT accept string in its value" do
        assert !@supplies_supply_size.accept_string?
      end
    end
    
    context "with a not blank value and belonging to a supply_size which NOT accept string" do
      setup do
        @supplies_supply_size.value = 10
        @supplies_supply_size.supply_size = supply_sizes(:not_accept_string)
      end
      
      subject{@supplies_supply_size}
      
      should_validate_numericality_of :value
    end
    
  end
end
