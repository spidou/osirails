require File.dirname(__FILE__) + '/../purchases_test'

class ParcelItemTest < ActiveSupport::TestCase
  
  should_belong_to :parcel, :purchase_order_supply, :issue_purchase_order_supply
  
  should_validate_presence_of :purchase_order_supply_id
  should_validate_numericality_of :quantity
  
  context "A new parcel item" do
    
    setup do
      @parcel = Parcel.new
      @parcel = build_parcel_item_for(@parcel, nil)
    end
    
    should "have a valid quantity" do
      @parcel.valid?
      assert !@parcel.parcel_items.first.errors.invalid?(:quantity)
    end
    
    should "have a good total price" do
      expected_result = 18000   #quantity * (fob_unit_price * (1 *( taxes / 100)))
                                # => 1000 * ( 12            * (1 *(    50 / 100))) 
      assert_equal expected_result, @parcel.parcel_items.first.parcel_item_total
    end
    
    context "which have a invalid quantity" do
      setup do
        @parcel.parcel_items.first.quantity *= @parcel.parcel_items.first.quantity 
      end
      
      should "through a validity error" do
        @parcel.valid?
        assert_match /quantity not valid/, @parcel.parcel_items.first.errors.on(:quantity)
      end
    end
    
    should "be able to be save" do
      @parcel.save!
      assert @parcel.parcel_items.select(&:new_record?).empty?
    end
  end 
  
  context "A parcel item" do
    setup do
      @parcel = Parcel.new
      @parcel = build_parcel_item_for(@parcel, nil)
      @parcel.save!
    end
      
    context "which have a not received associated parcel" do
        
      should "not be cancelled" do
        assert !@parcel.parcel_items.first.cancelled?
      end
        
      should "be able to be cancelled" do
        assert @parcel.parcel_items.first.can_be_cancelled?
      end
        
      should "return true if you cancel it" do
        @parcel.parcel_items.first.cancelled_comment = "cancelled parcel item"
        assert @parcel.parcel_items.first.cancel   
      end
    end  
      
    context "which have a received associated parcel" do
        
      setup do
        @parcel = put_received_status_for(@parcel)
      end
        
      should "not have possibility to be cancelled" do
        assert !@parcel.parcel_items.first.can_be_cancelled?
      end
      
      should "have possibility to be reported" do
        assert @parcel.parcel_items.first.can_be_reported?
      end
      
      should "be reported with a good quantity" do
        @parcel.parcel_items.first.issues_comment = "parcel item issues comment"
        @parcel.parcel_items.first.issues_quantity = 100
        assert @parcel.parcel_items.first.report
      end
      
      should "not be reported with a bad quantity" do
        @parcel.parcel_items.first.issues_comment = "parcel item issues comment"
        @parcel.parcel_items.first.issues_quantity = 2000
        @parcel.parcel_items.first.report
        assert_match /quantity not valid/, @parcel.parcel_items.first.errors.on(:issues_quantity)
      end
      
      context "and which is reported whithout reshipment" do
        setup do
          @parcel.parcel_items.first.issues_comment = "parcel item issues comment"
          @parcel.parcel_items.first.issues_quantity = 100
          flunk "parcel_item should be reported" unless @parcel.parcel_items.first.report
        end
          
        subject {@parcel.parcel_items.first}
        should_validate_presence_of :issues_comment
        should_validate_numericality_of :issues_quantity
      
        should "be reported" do
          assert @parcel.parcel_items.first.was_reported?
        end
          
        should "have possibility to be reported" do
          assert @parcel.parcel_items.first.can_be_reported?
        end
          
        should "not have a issue purchase order" do
          assert_nil @parcel.parcel_items.first.issue_purchase_order_supply 
        end
      end
      
      context "and which is reported with reshipment" do
        setup do
          @parcel.parcel_items.first.issues_comment = "parcel item issues comment"
          @parcel.parcel_items.first.issues_quantity = 100
          @parcel.parcel_items.first.must_be_reshipped = true
          flunk "parcel_item should be reported" unless @parcel.parcel_items.first.report
        end
          
        subject {@parcel.parcel_items.first}
        should_validate_presence_of :issues_comment
        should_validate_numericality_of :issues_quantity
        
        should "be reported" do
          assert @parcel.parcel_items.first.was_reported?
        end
        
        should "have possibility to be reported" do
          assert @parcel.parcel_items.first.can_be_reported?
        end
        
        should "have a issue purchase order" do
          assert_not_nil @parcel.parcel_items.first.issue_purchase_order_supply 
        end
        
        should "destroy issue purchase order if must_be_reshipped is deselected" do
          @parcel.parcel_items.first.must_be_reshipped = false
          @parcel.parcel_items.first.report
          assert_nil @parcel.parcel_items.first.issue_purchase_order_supply
        end
      end
    end      
    
    context "which is cancelled" do
      
      setup do
        @parcel.parcel_items.first.cancelled_comment = "cancelled parcel item"
        flunk "parcel item should be cancelled" unless @parcel.parcel_items.first.cancel
      end
      
      subject {@parcel.parcel_items.first}
      
      should_validate_presence_of :cancelled_comment
      
      should "be cancelled" do
        assert @parcel.parcel_items.first.was_cancelled?
      end
      
      should "not be able to be cancelled" do
        assert !@parcel.parcel_items.first.can_be_cancelled?
      end
    end 
  end
end
