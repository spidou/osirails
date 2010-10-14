require File.dirname(__FILE__) + '/../purchases_test'

class PurchasePriorityTest < ActiveSupport::TestCase
 
   context "A Purchase priority with default" do
    setup do
      @purchase_priority = PurchasePriority.new({:name => "regular", :default => true})
      @purchase_priority.save!
    end
    subject { @purchase_priority }
    should_validate_uniqueness_of :name
    
    context "when an other purchase priority is set without default" do
      setup do
        @other_purchase_priority = PurchasePriority.new({:name => "hight"})
        @other_purchase_priority.save!
      end
      
      should "let defaut in first purchase priority" do
        assert_equal @purchase_priority, PurchasePriority.default_priority
      end
      
      should "let true value on default column for @purchase_priority" do
        assert @purchase_priority.default
      end
    end
    
    context "when an other purchase priority is set with default" do
      setup do
        @other_purchase_priority = PurchasePriority.new({:name => "low", :default => true})
        @other_purchase_priority.save!
      end
      
      should "NOT let defaut in first purchase priority" do
        assert_not_equal @purchase_priority, PurchasePriority.default_priority
      end
      
      should "put other_purchase_priority in default_priority" do
         assert_equal @other_purchase_priority, PurchasePriority.default_priority
      end
      
      should "NOT let true value on default column for @purchase_priority" do
        assert !@purchase_priority.reload.default
      end
    end
  end
end
