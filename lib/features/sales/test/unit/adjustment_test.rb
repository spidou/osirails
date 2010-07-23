require File.dirname(__FILE__) + '/../sales_test'
 
class AdjustmentTest < ActiveSupport::TestCase
  should_belong_to :due_date
  
  should_have_attached_file :attachment
  
  should_validate_presence_of :comment
  
  should_validate_numericality_of :amount # I write another tests because validate_numericality cannot take in account than zero is forbidden
  
  #TODO test validates_persistence_of :due_date_id, :amount, :comment, :attachment_file_name, :attachment_file_size, :attachment_content_type
  
  context "A new adjustment" do
    setup do
      @adjustment = Adjustment.new
    end
    
    teardown do
      @adjustment = nil
    end
    
    [-100, -1.377, 0.5, 25.5, 128172].each do |good_value|
      should "have a valid amount when it's equal to #{good_value}" do
        @adjustment.amount = good_value
        @adjustment.valid?
        
        assert !@adjustment.errors.invalid?(:amount)
      end
    end
    
    [0, 0.0].each do |bad_value|
      should "have a invalid amount when it's equal to #{bad_value}" do
        @adjustment.amount = bad_value
        @adjustment.valid?
        
        assert @adjustment.errors.invalid?(:amount)
      end
    end
  end
end
