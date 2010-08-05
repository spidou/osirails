require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseRequestTest < ActiveSupport::TestCase
  
  should_have_many :purchase_request_supplies
  should_belong_to :user, :employee, :service
  
  should_validate_presence_of :user_id, :employee_id, :service_id
  
  context "A new purchase_request" do
    
    setup do
      @purchase_request = PurchaseRequest.new()
    end
    
    context "without purchase request supplies" do 
     
      should "have an invalid purchase_request_supplies" do
        @purchase_request.valid?
        assert_match /Vous devez choisir au moins une fourniture/, @purchase_request.errors.on(:purchase_request_supplies)
      end
    end
    
    context "which been able to build a purchase request supply" do
      
      context "with 'purchase_request_supply_attributes=' " do
        setup do
          flunk "purchase request should not have purchase request supplies" if @purchase_request.purchase_request_supplies.any?
          @purchase_request.purchase_request_supply_attributes = [{:supply_id => 1, 
                                                              :expected_delivery_date => Date.today + 1.week, 
                                                              :expected_quantity => 200}]
           flunk "purchase request should  have purchase request supplies" unless (@purchase_request_supply  = @purchase_request.purchase_request_supplies.first)
        end
        
        should "have new record of purchase request supply" do
          assert @purchase_request_supply.new_record?
        end
      end
    
      context "when saving purchase request" do
        
        setup do
          @purchase_request.purchase_request_supplies.build({:supply_id => 2,
                                                              :expected_delivery_date => nil, 
                                                              :expected_quantity => 200})
          @purchase_request.global_date = Date.today + 1.day
          @purchase_request.user_id = 1
          @purchase_request.employee_id = 2
          @purchase_request.service_id = 3
          flunk "purchase request should be saved" unless @purchase_request.save!
          flunk "purchase request supply should be saved" unless (@purchase_request_supply = @purchase_request.purchase_request_supplies.first)
          
        end
      
        should "be able to take purchase request global date if expected_delivery_date is not define" do
          assert_equal  Date.today + 1.day, @purchase_request_supply.expected_delivery_date
        end  
      end
    end
    
    context "with at least one purchase request supply" do 
      
      setup do
        @purchase_request = build_purchase_request_supplies_for(@purchase_request, 1)
      end
      
      should "have purchase_request_supplies valid" do
        @purchase_request.valid?
        assert !@purchase_request.errors.invalid?(:purchase_request_supplies)
      end
    end 
    
  end
  
  context "A valid purchase request" do
    setup do
      @purchase_request = PurchaseRequest.new()
      @purchase_request = build_purchase_request_supplies_for(@purchase_request, 2)
      @purchase_request.user_id = 1
      @purchase_request.employee_id = 2
      @purchase_request.service_id = 3
      flunk "purchase request should be valid" unless @purchase_request.valid?
    end
    
    should "be able to be saved" do
      assert @purchase_request.save! 
    end
  end
  
  context "A purchase_request" do
    
    setup do
      @purchase_request = create_purchase_request
    end
    
    subject {@purchase_request}
    
    should_validate_presence_of :reference
    
    context "which have purchase request supply" do
      setup do
        flunk "purchase request should have at least one purchase request supply" unless (@purchase_request_supply = @purchase_request.purchase_request_supplies.first)
        @purchase_request_supply.expected_quantity = 123
      end
      
      should "be able to update a purchase request supply with 'purchase_request_supply_attributes' " do

        @purchase_request.purchase_request_supply_attributes = [@purchase_request_supply.attributes]
        assert_equal 123, @purchase_request.purchase_request_supplies.first.expected_quantity
      end
    end
    
    context "which not have purchase order associated" do
      
      should "return untreated purchase request supplies" do
        assert_equal 2, @purchase_request.untreated_purchase_request_supplies.size
      end
      
      should "NOT return treated purchase request supplies" do
          assert_equal 0, @purchase_request.treated_purchase_request_supplies.size
      end
      
      should "NOT return during_treatment purchase request supplies" do
          assert_equal 0, @purchase_request.during_treatment_purchase_request_supplies.size
      end
      
    end
     
    context "which have purchase order associated" do
      setup do
        create_association_with_purchase_order_for(@purchase_request.purchase_request_supplies)
      end
      
      context "which is during treatment" do
        
        should "return during treatement purchase request supplies" do
          assert_equal 1, @purchase_request.during_treatment_purchase_request_supplies.size
        end
        
        should "NOT return untreated purchase request supplies" do
          assert_equal 0, @purchase_request.untreated_purchase_request_supplies.size
        end
      end
      
      context "which is treated" do
        
        should "return treated purchase request supplies" do
          assert_equal 1, @purchase_request.treated_purchase_request_supplies.size
        end

        should "NOT return untreated purchase request supplies" do
          assert_equal 0, @purchase_request.untreated_purchase_request_supplies.size
        end
      end
      
    end 
      
    context "which is not cancelled" do
      
      should "not be cancelled" do
        assert !@purchase_request.cancelled?
      end
    
      should "have possibility to be cancelled" do
        assert @purchase_request.can_be_cancelled?
      end
      
      context "whithout cancelled comment" do
        
        should "not be able to be cancel" do
          assert !@purchase_request.cancel
        end  
      end
      
      context "whithout canceller id" do
        
        should "not be able to be cancel" do
          assert !@purchase_request.cancel
        end  
      end
      
      should "be able to be cancel" do
        @purchase_request.cancelled_by_id = 1
        @purchase_request.cancelled_comment = "cancelled test"
        assert @purchase_request.cancel
      end
    end
    
    context "which is cancelled" do
      
      setup do
        @purchase_request = create_cancelled_purchase_request
      end
      
      subject {@purchase_request}
      
      should_validate_presence_of :cancelled_by_id, :cancelled_comment
      #TODO should_validate_persistence_of :cancelled_by_id, :cancelled_comment, :cancelled_at
      
      should "be cancelled" do
        assert @purchase_request.cancelled?
      end
      
      should "not have possibility to be cancelled" do
        assert !@purchase_request.can_be_cancelled?
      end 
    end
  end
end
