require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseOrderPaymentTest < ActiveSupport::TestCase
  
  should_belong_to  :purchase_order
  should_belong_to  :deposit_payment_method
  should_belong_to  :balance_payment_method
  
  should_validate_presence_of :purchase_order_id
  should_validate_presence_of :comment
  
  should_validate_numericality_of :deposit_amount
  
  context "A new purchase order payment" do
    setup do
      @purchase_order_payment = PurchaseOrderPayment.new
    end
    
    context "when deposit amount is set" do
      setup do
        @purchase_order_payment.deposit_amount = 300
      end
      
      context "and deposit_payment_method isn't set" do
        setup do
          @purchase_order_payment.valid?
        end
        should "have an error on deposit_payment_method_id" do
          assert_not_nil @purchase_order_payment.errors.on(:deposit_payment_method_id)
        end
      end
      context "and deposit_payment_method is set" do
        setup do
          @purchase_order_payment.deposit_payment_method_id = 1
          @purchase_order_payment.valid?
        end
        should "NOT have an error on deposit_payment_method_id" do
          assert_nil @purchase_order_payment.errors.on(:deposit_payment_method_id)
        end
      end
    end
    
    context "when payment_before_shipment is set and payment_on_delivery is set" do
      setup do
        @purchase_order_payment.payment_before_shipment = true
        @purchase_order_payment.payment_on_delivery = true
        @purchase_order_payment.valid?
      end
    
      should "have an error on payment_on_delivery" do
        assert_match /veuillez choisir 'paiement avant exp&eacute;dition' OU 'paiment &agrave; la livraison'/,  @purchase_order_payment.errors.on(@purchase_order_payment)
      end
    end
    
  end
end
