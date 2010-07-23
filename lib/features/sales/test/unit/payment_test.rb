require File.dirname(__FILE__) + '/../sales_test'
 
class PaymentTest < ActiveSupport::TestCase
  should_belong_to :due_date, :payment_method
  
  should_have_attached_file :attachment
  
  should_validate_presence_of :paid_on
  
  should_validate_numericality_of :amount # I wrote another tests because validate_numericality cannot take in account than zero is forbidden
  
  #TODO test validates_persistence_of :due_date_id, :payment_method_id, :amount, :paid_on, :attachment_file_name, :attachment_file_size, :attachment_content_type
  
  context "A new payment" do
    setup do
      @payment = Payment.new
    end
    
    teardown do
      @payment = nil
    end
    
    [-100, -1.377, 0.5, 25.5, 128172].each do |good_value|
      should "have a valid amount when it's equal to #{good_value}" do
        @payment.amount = good_value
        @payment.valid?
        
        assert !@payment.errors.invalid?(:amount)
      end
    end
    
    [0, 0.0].each do |bad_value|
      should "have a invalid amount when it's equal to #{bad_value}" do
        @payment.amount = bad_value
        @payment.valid?
        
        assert @payment.errors.invalid?(:amount)
      end
    end
  end
end
