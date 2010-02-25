require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class DueDateTest < ActiveSupport::TestCase
  #TODO test has_permissions
  
  should_belong_to :invoice
  
  should_have_many :payments, :dependent => :nullify
  should_have_many :adjustments, :dependent => :nullify
  
  should_validate_presence_of :date
  should_validate_numericality_of :net_to_paid
  
  #TODO test validates_persistence_of :date, :net_to_paid, :payments
  
  context "In an order with a 'non-factorised' and 'confirmed' invoice with 1 due_date, that due_date" do
    #TODO should be editable, etc...
  end
  
  context "In an order with a 'non-factorised' and 'sended' invoice with 1 due_date" do
    setup do
      @order = create_default_order
      @invoice = create_sended_deposit_invoice_for(@order)
      
      flunk "@invoice should be 'non-factorised'" if @invoice.factorised?
      flunk "@invoice should be 'sended'" unless @invoice.was_sended?
      flunk "@invoice should have 1 due_date" unless @invoice.due_dates.count == 1
    end
    
    teardown do
      @order = @invoice = nil
    end
    
    context "which is unpaid, it" do
      setup do
        @due_date = @invoice.due_dates.first
        
        flunk "@due_date should NOT be paid" if @due_date.was_paid?
      end
      
      teardown do
        @due_date = nil
      end
      
      #should "NOT be editable" do
      #  assert !@due_date.can_be_edited?, "#{@due_date.invoice.can_be_edited?} : #{@due_date.invoice.was_uncomplete?}\n#{@due_date.invoice.inspect}\n#{@invoice.inspect}"
      #end
      
      should "have 0 payments" do
        assert_equal 0, @due_date.payments.count
      end
      
      should "have 0 adjustments" do
        assert_equal 0, @due_date.adjustments.count
      end
      
      should "have a total_amounts equal to 0" do
        assert_equal 0, @due_date.total_amounts
      end
      
      should "NOT be 'paid?'" do
        assert !@due_date.paid?
      end
      
      should "NOT be 'was_paid?'" do
        assert !@due_date.was_paid?
      end
      
      should "NOT have a paid_on value" do
        assert_nil @due_date.paid_on
      end
      
      should "be able to be paid" do
        assert @due_date.can_be_paid?
      end
      
      [1,3,4].each do |x|
        should "build #{x} payments when calling 'payment_attributes=' with #{x} elements" do
          build_payments_on(@due_date, x)
          
          assert_equal x, @due_date.payments.size
        end
        
        should "build #{x} adjustments when calling 'adjustment_attributes=' with #{x} elements" do
          build_adjustments_on(@due_date, x)
          
          assert_equal x, @due_date.adjustments.size
        end
      end
    end
    
    context "which is paid with payments only, it" do
      setup do
        pay_invoice_with_payments_only(@invoice)
        @due_date = @invoice.due_dates.first
        
        flunk "@due_date should be paid" unless @due_date.was_paid?
        flunk "@due_date should have 1 payment" unless @due_date.payments.count == 1
        flunk "@due_date should have 0 adjustment" unless @due_date.adjustments.count == 0
      end
      
      teardown do
        @due_date.payments.destroy_all
        @due_date = nil
      end
      
      #should "NOT be editable" do
      #  assert !@due_date.can_be_edited?
      #end
      
      should "have 1 payment" do
        assert_equal 1, @due_date.payments.count
      end
      
      should "have 0 adjustments" do
        assert_equal 0, @due_date.adjustments.count
      end
      
      should "have a total_amounts equal to the amount of the payment" do
        assert_equal @due_date.payments.first.amount, @due_date.total_amounts
      end
      
      should "be 'paid?'" do
        assert @due_date.paid?
      end
      
      should "be 'was_paid?'" do
        assert @due_date.was_paid?
      end
      
      should "have a paid_on value" do
        assert @due_date.paid_on
      end
      
      should "NOT be able to be paid" do
        assert !@due_date.can_be_paid?
      end
      
      [1,3,4].each do |x|
        should "NOT build #{x} payments when calling 'payment_attributes='" do
          before_size = @due_date.payments.size
          
          build_payments_on(@due_date, x)
          assert_equal before_size, @due_date.payments.size
        end
        
        should "NOT build #{x} adjustments when calling 'adjustment_attributes='" do
          before_size = @due_date.adjustments.size
          
          build_adjustments_on(@due_date, x)
          assert_equal before_size, @due_date.adjustments.size
        end
      end
    end
    
    context "which is paid with payments and adjustments, it" do
      setup do
        pay_invoice_with_payments_and_adjustments(@invoice)
        @due_date = @invoice.due_dates.first
        
        flunk "@due_date should be paid" unless @due_date.was_paid?
        flunk "@due_date should have 1 payment" unless @due_date.payments.count == 1
        flunk "@due_date should have 1 adjustment" unless @due_date.adjustments.count == 1
      end
      
      teardown do
        #@due_date.payments.destroy_all #TODO uncomment that line
        @due_date = nil
      end
      
      #should "NOT be editable" do
      #  assert !@due_date.can_be_edited?
      #end
      
      should "have 1 payment" do
        assert_equal 1, @due_date.payments.count
      end
      
      should "have 1 adjustment" do
        assert_equal 1, @due_date.adjustments.count
      end
      
      should "have a total_amounts equal to the sum of payments and adjustments amounts" do
        assert_equal @due_date.payments.first.amount + @due_date.adjustments.first.amount, @due_date.total_amounts
      end
      
      should "be 'paid?'" do
        assert @due_date.paid?
      end
      
      should "be 'was_paid?'" do
        assert @due_date.was_paid?
      end
      
      should "have a paid_on value" do
        assert @due_date.paid_on
      end
      
      should "NOT be able to be paid" do
        assert !@due_date.can_be_paid?
      end
      
      [1,3,4].each do |x|
        should "NOT build #{x} payments when calling 'payment_attributes='" do
          before_size = @due_date.payments.size
          
          build_payments_on(@due_date, x)
          assert_equal before_size, @due_date.payments.size
        end
        
        should "NOT build #{x} adjustments when calling 'adjustment_attributes='" do
          before_size = @due_date.adjustments.size
          
          build_adjustments_on(@due_date, x)
          assert_equal before_size, @due_date.adjustments.size
        end
      end
    end
  end
  
  private
    def pay_invoice_with_payments_only(invoice)
      due_date = invoice.due_dates.first
      attributes = { :due_date_to_pay => { :id => due_date.id,
                                           :payment_attributes => [ { :paid_on           => Date.today,
                                                                      :amount            => due_date.net_to_paid,
                                                                      :payment_method_id => payment_methods(:bank_transfer).id } ] } }
      invoice.totally_pay(attributes)
    end
    
    def pay_invoice_with_payments_and_adjustments(invoice)
      due_date = invoice.due_dates.first
      penalty = due_date.net_to_paid / 1.10 # net_to_paid - 10%
      
      attributes = { :due_date_to_pay => { :id => due_date.id,
                                           :payment_attributes    => [ { :paid_on           => Date.today,
                                                                         :amount            => due_date.net_to_paid - penalty,
                                                                         :payment_method_id => payment_methods(:bank_transfer).id } ],
                                           :adjustment_attributes => [ { :amount  => penalty,
                                                                         :comment => "This is a penalty" } ] } }
      invoice.totally_pay(attributes)
    end
    
    # quantity => number of payments to build
    def build_payments_on(due_date, quantity)
      attributes = []
      quantity.times do |x|
        attributes << { :paid_on => Date.today,
                        :amount  => ( due_date.net_to_paid / quantity ) }
      end
      due_date.payment_attributes=(attributes)
    end
    
    # quantity => number of adjustments to build
    def build_adjustments_on(due_date, quantity)
      attributes = []
      quantity.times do |x|
        attributes << { :amount   => 100,
                        :comment  => "This is a overdue" }
      end
      due_date.adjustment_attributes=(attributes)
    end
end
