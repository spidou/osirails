require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceTest < ActiveSupport::TestCase
  
  #TODO test has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :due_date_pay]
  #TODO test has_address     :bill_to_address
  #TODO test has_contact     :accept_from => :order_contacts
  
  should_belong_to :order, :invoice_type, :cancelled_by, :abandoned_by
  
  should_have_many :invoice_items
  should_have_many :products, :through => :invoice_items
  should_have_many :product_items
  should_have_many :free_items
  
  should_have_many :delivery_notes
  should_have_many :dunnings
  should_have_many :due_dates
  
  should_have_one :upcoming_due_date
  
  #should_validate_presence_of :bill_to_address
  #should_validate_presence_of :invoice_type, :with_foreign_key => :default
  
  #TODO put validates_inclusion_of :status on each step of the test (according contexts)
  #should_not_allow_values_for :status, 0, 1, "0", "1", "string"
  #should_allow_values_for :status, nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_TOTALLY_PAID
  
  should_not_allow_mass_assignment_of :status, :reference, :cancelled_by, :abandoned_by, :confirmed_at, :cancelled_at
  
  #TODO test all validates_date
  
  context "In an order with 2 products and NO signed_quote, a new invoice" do
    setup do
      @order = create_default_order
      2.times do
        create_valid_product_for(@order)
      end
      
      flunk "order should have at least 2 contacts to perform the following, but has #{@order.contacts.count}" unless @order.contacts.count >= 2
      
      @invoice = @order.invoices.build
      @invoice.valid?
    end
    
    teardown do
      @order = @invoice = nil
    end
    
    should "require at least 1 invoice_item" do
      assert @invoice.errors.invalid?(:invoice_item_ids)
      
      @invoice.invoice_items.build
      @invoice.valid?
      assert !@invoice.errors.invalid?(:invoice_item_ids)
      
      @invoice.invoice_items.build
      @invoice.valid?
      assert !@invoice.errors.invalid?(:invoice_item_ids)
    end
    
    should "require exactly 1 contact" do
      assert @invoice.errors.invalid?(:contact_ids)
      
      @invoice.contacts << @order.contacts.first
      @invoice.valid?
      assert !@invoice.errors.invalid?(:contact_ids)
      
      @invoice.contacts << @order.contacts.last
      @invoice.valid?
      assert @invoice.errors.invalid?(:contact_ids)
    end
    
    should "require at least 1 due_date" do
      assert @invoice.errors.invalid?(:due_date_ids)
      
      @invoice.due_dates.build
      @invoice.valid?
      assert !@invoice.errors.invalid?(:due_date_ids)
      
      @invoice.due_dates.build
      @invoice.valid?
      assert !@invoice.errors.invalid?(:due_date_ids)
    end
    
    should "build invoice_items for each order's products when calling 'build_invoice_items_from_products'" do
      @invoice.build_invoice_items_from_products
      
      assert_equal @order.products.count, @invoice.invoice_items.size
    end
    
    should "build 1 invoice_item for a specific product calling 'build_invoice_item_from(product)'" do
      @invoice.build_invoice_item_from(@order.products.first)
      
      assert_equal 1, @invoice.invoice_items.size
    end
  end
  
  context "In an order without signed quote" do
    # should NOT be able to have facture d'acompte
    # should NOT be able to have autres factures
  end
  
  context "In an order with a signed quote and NO signed delivery_note" do
    # should be able to have deposit invoices
    # should NOT be able to have other invoices
  end
  
  context "In an order with a signed quote and 1 signed delivery_note," do
    # should be able to have deposit invoices
    # should be able to have other invoices
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_delivery_note_for(@order)
      
      flunk "order should have at least 2 contacts to perform the following, but has #{@order.contacts.count}" if @order.contacts.count < 2
      
      @invoice = @order.invoices.build
    end
    
    teardown do
      @order = @signed_quote = @delivery_note = @invoice = nil
    end
    
    context "a new invoice" do
      setup do
        @invoice.valid?
      end
      
      should "have an associated_quote" do
        assert_equal @signed_quote, @invoice.associated_quote
      end
      
      should "build invoice_items when calling 'invoice_item_attributes='" do
        attributes = []
        @order.products.each do |p|
          attributes << { :product_id => p.id,
                          :quantity   => p.quantity,
                          :discount   => p.discount }
        end
        @invoice.invoice_item_attributes=(attributes)
        
        assert_equal @order.products.count, @invoice.invoice_items.size
      end
      
      [1,3,4].each do |x|
        should "build #{x} free_items when calling 'invoice_item_attributes='" do
          x.times { build_free_item_for(@invoice) }
          
          assert_equal x, @invoice.invoice_items.size
        end
        
        should "build #{x} due_dates when calling 'due_date_attributes=' with #{x} due_dates" do
          build_due_dates_for(@invoice, x)
          
          assert_equal x, @invoice.due_dates.size
        end
      end
    end
    
    context "a new and ready-to-be-saved invoice" do
      setup do
        prepare_invoice_to_be_saved(@invoice)
        
        flunk "@invoice should be valid to perform the following > #{@invoice.due_dates.first.errors.inspect}" unless @invoice.valid?
      end
      
      teardown do
        @invoice = nil
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, nil
      should_not_allow_values_for :status, 1, "string", Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID
      
      should_validate_presence_of :bill_to_address
      should_validate_presence_of :invoice_type, :with_foreign_key => :default
      
      should "save invoice_items after saving itself" do
        @invoice.save!
        
        assert_equal @order.products.count, @invoice.invoice_items.count
        assert_equal 0, @invoice.free_items.count
        assert_equal @order.products.count, @invoice.product_items.count
      end
      
      [1,3,4].each do |x|
        should "save #{x} free_items after saving itself" do
          x.times { build_free_item_for(@invoice) }
          @invoice.save!
          
          assert_equal @order.products.count + x, @invoice.invoice_items.count
          assert_equal x, @invoice.free_items.count
          assert_equal @order.products.count, @invoice.product_items.count
        end
        
        should "save #{x} due_dates when saving itself" do
          @invoice.due_dates = [] #empty due dates
          build_due_dates_for(@invoice, x)
          
          @invoice.save!
          
          assert_equal x, @invoice.due_dates.count
        end
      end
    end
    
    # tests for UNCOMPLETE and NORMAL invoice
    context "a saved (uncomplete) and normal invoice" do
      setup do
        create_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, nil, Invoice::STATUS_CONFIRMED
      should_not_allow_values_for :status, 1, "string", Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID
      
      should_validate_presence_of :bill_to_address
      should_validate_presence_of :invoice_type, :with_foreign_key => :default
      
      #TODO test validates_persistence_of :order_id, :invoice_type_id, :factorised
        
      should "validate due_dates has no size limit" do
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
        
        build_due_dates_for(@invoice, 2)
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
        
        build_due_dates_for(@invoice, 5)
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
      end
      
      should "NOT be factorised" do
        assert !@invoice.factorised?
      end
      
      should "be able to be edited" do
        assert @invoice.can_be_edited?
      end
      
      should "be edited" do
        assert_invoice_can_be_edited(@invoice)
      end
      
      should "be able to be destroyed" do
        assert @invoice.can_be_destroyed?
      end
      
      should "be destroyed" do
        assert @invoice.destroy
      end
      
      should "be able to be confirmed" do
        assert @invoice.can_be_confirmed?
      end
      
      should "be confirmed" do
        confirm_invoice(@invoice)
        assert @invoice.was_confirmed?
      end
      
      should "NOT be able to be cancelled" do
        assert !@invoice.can_be_cancelled?
      end
      
      should "NOT be cancelled" do
        cancel_invoice(@invoice)
        assert !@invoice.was_cancelled?
      end
      
      should "NOT be able to be sended" do
        assert !@invoice.can_be_sended?
      end
      
      should "NOT be sended" do
        send_invoice(@invoice)
        assert !@invoice.was_sended?
      end
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      should "NOT be totally_paid" do
        totally_pay_invoice(@invoice)
        assert !@invoice.was_totally_paid?
      end
      
      context "which is going to be CONFIRMED" do
        setup do
          @invoice.status = Invoice::STATUS_CONFIRMED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :confirmed_at, :reference
        #TODO test validates_date :confirmed_at, :on_or_after => :created_at, :on_or_after_message => "ne doit pas être AVANT la date de création de la facture&#160;(%s)"
      end
    end
    
    # tests for UNCOMPLETE and FACTORISED invoice
    context "a saved (uncomplete) and factorised invoice" do
      setup do
        create_invoice(@invoice, :factorised)
      end
      
      should "validate maximum size of due_dates is 1" do
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
        
        build_due_dates_for(@invoice, 2)
        @invoice.valid?
        assert @invoice.errors.invalid?(:due_dates)
      end
      
      should "be factorised" do
        assert @invoice.factorised?
      end
    end
    
    # tests for CONFIRMED invoice
    context "a confirmed invoice" do
      setup do
        @expected_reference = get_next_expected_reference
        prepare_confirmed_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID
      
      #TODO test validates_persistence_of :confirmed_at, :reference, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :contact
      
      should "have a unique reference" do
        assert @invoice.reference
        assert_equal @expected_reference, @invoice.reference
      end
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed 'again'" do
        assert !@invoice.can_be_confirmed?
      end
      
      #should "NOT be confirmed" do
      #  confirm_invoice(@invoice)
      #  assert @invoice.was_confirmed?
      #end
      
      should "be able to be cancelled" do
        assert @invoice.can_be_cancelled?
      end
      
      should "be cancelled" do
        cancel_invoice(@invoice)
        assert @invoice.was_cancelled?, "#{@invoice.errors.inspect}"
      end
      
      should "be able to be sended" do
        assert @invoice.can_be_sended?
      end
      
      should "be sended" do
        send_invoice(@invoice)
        assert @invoice.was_sended?
      end
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      should "NOT be totally_paid" do
        totally_pay_invoice(@invoice)
        assert !@invoice.was_totally_paid?
      end
      
      context "which is going to be CANCELLED" do
        setup do
          @invoice.status = Invoice::STATUS_CANCELLED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :cancelled_at, :cancelled_comment
        should_validate_presence_of :cancelled_by, :with_foreign_key => :default
        
        #TODO test validates_date :cancelled_at, :on_or_after => :confirmed_at, :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
      end
      
      context "which is going to be SENDED" do
        setup do
          @invoice.status = Invoice::STATUS_SENDED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :sended_on
        should_validate_presence_of :send_invoice_method, :with_foreign_key => :default
        
        #TODO test validates_date :sended_on, :on_or_after => :confirmed_at, :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
      end
    end
    
    # tests for CANCELLED invoice
    context "a cancelled invoice" do
      setup do
        prepare_cancelled_invoice(@invoice)
      end
      
      #TODO test validates_persistence_of :status, :cancelled_at, :cancelled_comment, :cancelled_by_id
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@invoice.can_be_confirmed?
      end
      
      should "NOT be confirmed" do
        confirm_invoice(@invoice)
        assert !@invoice.was_confirmed?
      end
      
      should "NOT be able to be cancelled 'again'" do
        assert !@invoice.can_be_cancelled?
      end
      
      #should "NOT be cancelled" do
      #  cancel_invoice(@invoice)
      #  assert @invoice.was_cancelled?, "#{@invoice.errors.inspect}"
      #end
      
      should "NOT be able to be sended" do
        assert !@invoice.can_be_sended?
      end
      
      should "NOT be sended" do
        send_invoice(@invoice)
        assert !@invoice.was_sended?
      end
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      should "NOT be totally_paid" do
        totally_pay_invoice(@invoice)
        assert !@invoice.was_totally_paid?
      end
    end
    
    # tests for SENDED and NORMAL invoice
    context "a sended and normal invoice" do
      setup do
        prepare_sended_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_SENDED, Invoice::STATUS_CANCELLED, Invoice::STATUS_ABANDONED, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED
      
      #TODO test validates_persistence_of :sended_on
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@invoice.can_be_confirmed?
      end
      
      should "NOT be confirmed" do
        confirm_invoice(@invoice)
        assert !@invoice.was_confirmed?
      end
      
      should "be able to be cancelled" do
        assert @invoice.can_be_cancelled?
      end
      
      should "be cancelled" do
        cancel_invoice(@invoice)
        assert @invoice.was_cancelled?
      end
      
      should "NOT be able to be sended 'again'" do
        assert !@invoice.can_be_sended?
      end
      
      #should "NOT be sended" do
      #  send_invoice(@invoice)
      #  assert !@invoice.was_sended?
      #end
      
      should "be able to be abandoned" do
        assert @invoice.can_be_abandoned?
      end
      
      should "be abandoned" do
        abandon_invoice(@invoice)
        assert @invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?, "#{@invoice.errors.inspect}\n#{@invoice.due_dates.size}\n#{@invoice.due_dates.first.errors.inspect}\n#{@invoice.due_dates.first.payments.size}\n#{@invoice.due_dates.first.payments.first.errors.inspect unless @invoice.due_dates.first.payments.empty?}"
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "be able to be totally_paid" do
        assert @invoice.can_be_totally_paid?
      end
      
      should "be totally_paid" do
        totally_pay_invoice(@invoice)
        assert @invoice.was_totally_paid?
      end
      
      context "which is going to be CANCELLED" do
        setup do
          @invoice.status = Invoice::STATUS_CANCELLED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :cancelled_at, :cancelled_comment
        should_validate_presence_of :cancelled_by, :with_foreign_key => :default
        
        #TODO test validates_date :cancelled_at, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
      end
      
      context "which is going to be ABANDONED" do
        setup do
          @invoice.status = Invoice::STATUS_ABANDONED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :abandoned_on, :abandoned_comment
        should_validate_presence_of :abandoned_by, :with_foreign_key => :default
        
        #TODO test validates_date :abandoned_on, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    # tests for SENDED and FACTORISED invoice
    context "a sended and factorised invoice" do
      setup do
        prepare_sended_invoice(@invoice, :factorised)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_SENDED, Invoice::STATUS_CANCELLED, Invoice::STATUS_FACTORING_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID, Invoice::STATUS_ABANDONED
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "be able to be factoring_paid" do
        assert @invoice.can_be_factoring_paid?
      end
      
      should "be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert @invoice.was_factoring_paid?, "#{@invoice.errors.inspect}\n#{@invoice.due_dates.size}\n#{@invoice.due_dates.first.errors.inspect}\n#{@invoice.due_dates.first.payments.size}\n#{@invoice.due_dates.first.payments.first.errors.inspect}"
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      should "NOT be totally_paid" do
        totally_pay_invoice(@invoice)
        assert !@invoice.was_totally_paid?
      end
      
      context "which is going to be FACTORING_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_PAID
        end
        
        should "validate presence of factoring_payment" do
          @invoice.valid?
          @invoice.errors.invalid?(:factoring_payment)
        end
      end
    end
    
    # tests for ABANDONED invoice
    context "a abandoned invoice" do
      setup do
        prepare_abandoned_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED
      
      #TODO test validates_persistence_of :abandoned_on, :abandoned_comment, :abandoned_by_id
      
      #TODO all tests for abandoned invoice here
      
      context "which is going to be FACTORING_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_PAID
        end
        
        should "validate presence of factoring_payment" do
          @invoice.valid?
          @invoice.errors.invalid?(:factoring_payment)
        end
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    # tests for FACTORING_PAID invoice
    context "a factoring_paid invoice" do
      setup do
        prepare_factoring_paid_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_ABANDONED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@invoice.can_be_confirmed?
      end
      
      should "NOT be confirmed" do
        confirm_invoice(@invoice)
        assert !@invoice.was_confirmed?
      end
      
      should "NOT be able to be cancelled" do
        assert !@invoice.can_be_cancelled?
      end
      
      should "NOT be cancelled" do
        cancel_invoice(@invoice)
        assert !@invoice.was_cancelled?
      end
      
      should "NOT be able to be sended" do
        assert !@invoice.can_be_sended?
      end
      
      should "NOT be sended" do
        send_invoice(@invoice)
        assert !@invoice.was_sended?
      end
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid 'again'" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      #should "NOT be factoring_paid" do
      #  factoring_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_paid?
      #end
      
      should "be able to be factoring_recovered" do
        assert @invoice.can_be_factoring_recovered?
      end
      
      should "be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert @invoice.was_factoring_recovered?
      end
      
      should "be able to be totally_paid" do
        assert @invoice.can_be_totally_paid?
      end
      
      should "be totally_paid" do
        totally_pay_invoice(@invoice)
        assert @invoice.was_totally_paid?
      end
      
      context "which is going to be FACTORING_RECOVERED" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_RECOVERED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :factoring_recovered_on
        
        #TODO test validates_date :factoring_recovered_on, :on_or_after => :factoring_paid_on, :on_or_after_message => "ne doit pas être AVANT la date de réglement par le factor de la facture&#160;(%s)"
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    # tests for FACTORING_RECOVERED invoice
    context "a factoring_recovered invoice" do
      setup do
        prepare_factoring_recovered_invoice(@invoice)
      end
      
      subject { @invoice }
      
      #TODO test persistence_of :factoring_recovered_on
      
      should_allow_values_for :status, Invoice::STATUS_ABANDONED, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@invoice.can_be_confirmed?
      end
      
      should "NOT be confirmed" do
        confirm_invoice(@invoice)
        assert !@invoice.was_confirmed?
      end
      
      should "NOT be able to be cancelled" do
        assert !@invoice.can_be_cancelled?
      end
      
      should "NOT be cancelled" do
        cancel_invoice(@invoice)
        assert !@invoice.was_cancelled?
      end
      
      should "NOT be able to be sended" do
        assert !@invoice.can_be_sended?
      end
      
      should "NOT be sended" do
        send_invoice(@invoice)
        assert !@invoice.was_sended?
      end
      
      should "be able to be abandoned" do
        assert @invoice.can_be_abandoned?
      end
      
      should "be abandoned" do
        abandon_invoice(@invoice)
        assert @invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?
      end
      
      should "NOT be able to be factoring_recovered 'again'" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      #should "be factoring_recovered" do
      #  factoring_recover_invoice(@invoice)
      #  assert @invoice.was_factoring_recovered?
      #end
      
      should "be able to be totally_paid" do
        assert @invoice.can_be_totally_paid?
      end
      
      should "be totally_paid" do
        totally_pay_invoice(@invoice)
        assert @invoice.was_totally_paid?
      end
      
      context "which is going to be ABANDONED" do
        setup do
          @invoice.status = Invoice::STATUS_ABANDONED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :abandoned_on, :abandoned_comment
        should_validate_presence_of :abandoned_by, :with_foreign_key => :default
        
        #TODO test validates_date :abandoned_on, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    # tests for TOTALLY_PAID invoice
    context "a totally_paid invoice" do
      setup do
        prepare_totally_paid_invoice(@invoice)
      end
      
      subject { @invoice }
      
      #TODO test persistence_of :status
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_destroyed?
      end
      
      should "NOT be destroyed" do
        assert !@invoice.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@invoice.can_be_confirmed?
      end
      
      should "NOT be confirmed" do
        confirm_invoice(@invoice)
        assert !@invoice.was_confirmed?
      end
      
      should "NOT be able to be cancelled" do
        assert !@invoice.can_be_cancelled?
      end
      
      should "NOT be cancelled" do
        cancel_invoice(@invoice)
        assert !@invoice.was_cancelled?
      end
      
      should "NOT be able to be sended" do
        assert !@invoice.can_be_sended?
      end
      
      should "NOT be sended" do
        send_invoice(@invoice)
        assert !@invoice.was_sended?
      end
      
      should "NOT be able to be abandoned" do
        assert !@invoice.can_be_abandoned?
      end
      
      should "NOT be abandoned" do
        abandon_invoice(@invoice)
        assert !@invoice.was_abandoned?
      end
      
      should "NOT be able to be factoring_paid" do
        assert !@invoice.can_be_factoring_paid?
      end
      
      should "NOT be factoring_paid" do
        factoring_pay_invoice(@invoice)
        assert !@invoice.was_factoring_paid?
      end
      
      should "NOT be able to be factoring_recovered" do
        assert !@invoice.can_be_factoring_recovered?
      end
      
      should "NOT be factoring_recovered" do
        factoring_recover_invoice(@invoice)
        assert !@invoice.was_factoring_recovered?
      end
      
      should "NOT be able to be totally_paid 'again'" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert @invoice.was_totally_paid?
      #end
    end
  end
  
  private
    # quantity => number of due_dates to build
    def build_due_dates_for(invoice, quantity)
      invoice.due_dates = []
      
      attributes = []
      quantity.times do
        attributes << { :date         => Date.today + quantity.month,
                        :net_to_paid  => ( invoice.net_to_paid / quantity ) }
      end
      invoice.due_date_attributes=(attributes)
      
      flunk "invoice should have #{quantity} due_dates to perform the following" if invoice.due_dates.size != quantity
    end
    
    def build_free_item_for(invoice)
      before = invoice.invoice_items.size
      
      attributes = [{ :product_id   => nil,
                      :quantity     => 1,
                      :discount     => 0,
                      :name         => "This is a free line",
                      :description  => "And this is the description of the free line" }]
      invoice.invoice_item_attributes=(attributes)
      
      flunk "invoice should have one more invoice_item to perform the following" if invoice.invoice_items.size == before
    end
    
    def prepare_invoice_to_be_saved(invoice, factorised = :normal)
      invoice.factorised = true if factorised == :factorised
      invoice.invoice_type = InvoiceType.first
      invoice.contact = @order.contacts.first
      invoice.bill_to_address = @order.bill_to_address
      
      invoice.build_invoice_items_from_products
      
      build_due_dates_for(invoice, 1)
      
      return invoice
    end
    
    def prepare_confirmed_invoice(invoice, factorised = :normal)
      create_invoice(invoice, factorised)
      invoice = confirm_invoice(invoice)
      flunk "invoice should be confirmed to perform the following > #{invoice.status} : #{invoice.status_was}" unless invoice.was_confirmed?
    end
    
    def prepare_cancelled_invoice(invoice)
      prepare_confirmed_invoice(invoice)
      invoice = cancel_invoice(invoice)
      flunk "invoice should be cancelled to perform the following" unless invoice.was_cancelled?
    end
    
    def prepare_sended_invoice(invoice, factorised = :normal)
      prepare_confirmed_invoice(invoice, factorised)
      invoice = send_invoice(invoice)
      flunk "invoice should be sended to perform the following" unless invoice.was_sended?
    end
    
    def prepare_abandoned_invoice(invoice)
      prepare_sended_invoice(invoice)
      invoice = abandon_invoice(invoice)
      flunk "invoice should be abandoned to perform the following" unless invoice.was_abandoned?
    end
    
    def prepare_factoring_paid_invoice(invoice)
      prepare_sended_invoice(invoice, :factorised)
      invoice = factoring_pay_invoice(invoice)
      flunk "invoice should be factoring_paid to perform the following" unless invoice.was_factoring_paid?
    end
    
    def prepare_factoring_recovered_invoice(invoice)
      prepare_factoring_paid_invoice(invoice)
      invoice = factoring_recover_invoice(invoice)
      flunk "invoice should be factoring_recovered to perform the following" unless invoice.was_factoring_recovered?
    end
    
    def prepare_totally_paid_invoice(invoice)
      prepare_sended_invoice(invoice)
      invoice = totally_pay_invoice(invoice)
      flunk "invoice should be totally_paid to perform the following" unless invoice.was_totally_paid?
    end
    
    # param 'factorised' can be set at ':factorised' to create a factorised invoice
    def create_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice_to_be_saved(invoice, factorised)
      invoice.save!
      return invoice
    end
    
    def confirm_invoice(invoice)
      invoice.confirm
      return invoice
    end
    
    def cancel_invoice(invoice)
      attributes = { :cancelled_by_id => employees(:john_doe).id, :cancelled_comment => "this invoice is cancelled now" }
      invoice.cancel(attributes)
      return invoice
    end
    
    def send_invoice(invoice)
      attributes = { :send_invoice_method_id => send_invoice_methods(:fax).id }
      invoice.send_to_customer(attributes)
      return invoice
    end
    
    def abandon_invoice(invoice)
      attributes = { :abandoned_by_id => employees(:john_doe).id, :abandoned_comment => "this invoice is abandoned now" }
      invoice.abandon(attributes)
      return invoice
    end
    
    def factoring_pay_invoice(invoice)
      amount = invoice.net_to_paid * 0.9 # 90% of the total
      attributes = { :due_date_to_pay => { :id => invoice.due_dates.first.id,
                                           :payment_attributes => [ { :paid_on           => Date.today,
                                                                      :amount            => amount,
                                                                      :payment_method_id => payment_methods(:bank_transfer).id,
                                                                      :paid_by_factor    => true } ] } }
      invoice.factoring_pay(attributes)
      return invoice
    end
    
    def factoring_recover_invoice(invoice)
      invoice.factoring_recover
      return invoice
    end
    
    def totally_pay_invoice(invoice)
      amount = invoice.balance_to_be_paid
      attributes = { :due_date_to_pay => { :id => invoice.due_dates.first.id,
                                           :payment_attributes => [ { :paid_on           => Date.today,
                                                                      :amount            => amount,
                                                                      :payment_method_id => payment_methods(:bank_transfer).id,
                                                                      :paid_by_factor    => true } ] } }
      invoice.totally_pay(attributes)
      return invoice
    end
    
    
    def update_invoice(invoice)
      invoice.contact.first_name += "string"
      invoice.bill_to_address.street_name += "string"
      invoice.invoice_items.each { |i| i.discount += 2 }
      invoice.due_dates.each { |d| d.date += 1.week }
      return invoice
    end
    
    def assert_invoice_can_be_edited(invoice)
      before_contact_attributes           = invoice.contact.attributes
      before_bill_to_address_attributes   = invoice.bill_to_address.attributes
      before_invoice_item_attributes      = invoice.invoice_items.first.attributes
      before_due_date_attributes          = invoice.due_dates.first.attributes
      
      update_invoice(invoice)
      
      assert invoice.valid?, "#{invoice.errors.inspect}"
      assert !invoice.errors.invalid?(:contact)
      assert !invoice.errors.invalid?(:bill_to_address)
      assert !invoice.errors.invalid?(:invoice_items)
      assert !invoice.errors.invalid?(:due_dates)
      
      #flunk "#{invoice.due_dates.first.errors.inspect}" unless invoice.save
      #
      #assert_not_equal before_contact_ids,                  invoice.contact_ids
      #assert_not_equal before_bill_to_address_attributes,   invoice.bill_to_address.attributes
      #assert_not_equal before_invoice_item_attributes,      invoice.invoice_items.first.attributes
      #assert_not_equal before_due_date_attributes,          invoice.due_dates.first.attributes
    end
    
    def assert_invoice_cannot_be_edited(invoice)
      before_contact_attributes           = invoice.contact.attributes
      before_bill_to_address_attributes   = invoice.bill_to_address.attributes
      before_invoice_item_attributes      = invoice.invoice_items.first.attributes
      before_due_date_attributes          = invoice.due_dates.first.attributes
      
      update_invoice(invoice)
      
      assert !invoice.valid?
      assert invoice.errors.invalid?(:contact), "#{invoice.errors.inspect}"
      assert invoice.errors.invalid?(:bill_to_address)
      assert invoice.errors.invalid?(:invoice_items)
      assert invoice.errors.invalid?(:due_dates)
    end
    
    def get_next_expected_reference
      prefix = Date.today.strftime(Invoice::REFERENCE_PATTERN)
      last_invoice = Invoice.last(:conditions => [ "reference LIKE ?", "#{prefix}%" ])
      quantity = last_invoice ? last_invoice.reference.gsub(/^(#{prefix})/, '').to_i + 1 : 1
      "#{prefix}#{quantity.to_s.rjust(3,'0')}"
    end
end
