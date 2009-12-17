require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceTest < ActiveSupport::TestCase
  
  #TODO test has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :due_date_pay]
  #TODO test has_address     :bill_to_address
  #TODO test has_contact     :accept_from => :order_contacts
  
  should_belong_to :order, :invoice_type, :cancelled_by, :abandoned_by
  
  should_have_many :invoice_items
  should_have_many :products, :through => :invoice_items
  
  should_have_many :delivery_notes
  should_have_many :dunnings
  should_have_many :due_dates
  
  should_have_one :upcoming_due_date
  
  should_not_allow_mass_assignment_of :status, :reference, :cancelled_by, :abandoned_by, :confirmed_at, :cancelled_at
  
  context "Associated to a factorisable invoice_type, an invoice" do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @invoice = @order.invoices.build
      @invoice.invoice_type = invoice_types(:factorisable_invoice)
    end
    
    teardown do
      @order = @signed_quote = @invoice = nil
    end
    
    should "be able to be 'factorised'" do
      @invoice.factorised = true
      @invoice.valid?
      assert !@invoice.errors.invalid?(:factorised)
    end
    
    should "be able to be 'normal'" do
      @invoice.factorised = false
      @invoice.valid?
      assert !@invoice.errors.invalid?(:factorised)
    end
  end
  
  context "Associated to a nonfactorisable invoice_type, an invoice" do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @invoice = @order.invoices.build
      @invoice.invoice_type = invoice_types(:nonfactorisable_invoice)
    end
    
    teardown do
      @order = @signed_quote = @invoice = nil
    end
    
    should "NOT be able to be 'factorised'" do
      @invoice.factorised = true
      @invoice.valid?
      assert @invoice.errors.invalid?(:factorised)
    end
    
    should "be able to be 'normal'" do
      @invoice.factorised = false
      @invoice.valid?
      assert !@invoice.errors.invalid?(:factorised)
    end
  end
  
  context "In an order with NO signed_quote," do
    setup do
      @order = create_default_order
      2.times do
        create_valid_product_for(@order)
      end
      
      #flunk "order should have at least 2 contacts to perform the following, but has #{@order.contacts.count}" unless @order.contacts.count >= 2
      
      @invoice = @order.invoices.build
      @invoice.valid?
    end
    
    teardown do
      @order = @invoice = nil
    end
    
    [:deposit_invoice, :status_invoice, :balance_invoice, :asset_invoice].each do |type|
      context "a '#{type}' invoice" do
        setup do
          @invoice = @order.invoices.build
          @invoice.invoice_type = invoice_types(type)
          @invoice.valid?
        end
        
        teardown do
          @invoice = nil
        end
        
        should "be invalid because of missing signed_quote" do
          assert @invoice.errors.invalid?(:associated_quote)
        end
      end
    end
  end
  
  context "In an order with a signed quote" do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @invoice = @order.invoices.build
    end
    
    teardown do
      @order = @signed_quote = @invoice = nil
    end
    
    context "without an existing 'deposit' invoice, a 'deposit' invoice" do
      setup do
        flunk "@order should NOT have a deposit_invoice to perform the following" if @order.deposit_invoice
        
        prepare_deposit_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = @order.invoices.build
      end
      
      should "be able to be created" do
        assert @invoice.can_create_deposit_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?, "#{@invoice.net_to_paid} : #{@invoice.due_dates.first.errors.inspect}"
      end
      
      should "be saved successfully" do
        @invoice.save!
        assert !@invoice.new_record?
      end
      
      should "add a deposit_invoice on order" do
        @invoice.save!
        assert @order.deposit_invoice
      end
    end
    
    context "with an existing 'deposit' invoice, another 'deposit' invoice" do
      setup do
        @deposit_invoice = @order.invoices.build
        create_deposit_invoice(@deposit_invoice)
        flunk "@order should have a deposit_invoice to perform the following" unless @order.deposit_invoice
        
        prepare_deposit_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @order.deposit_invoice.destroy
        @deposit_invoice = nil
        @invoice = @order.invoices.build
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_deposit_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
        assert @invoice.errors.invalid?(:invoice_type)
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
    
    context ", a 'status' invoice" do
      setup do
        prepare_status_invoice(@invoice)
      end
      
      teardown do
        @invoice = @order.invoices.build
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_status_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
    
    context ", a 'balance' invoice" do
      setup do
        prepare_balance_invoice(@invoice)
      end
      
      teardown do
        @invoice = @order.invoices.build
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_balance_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
    
    context ", an 'asset' invoice" do
      setup do
        prepare_asset_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = @order.invoices.build
      end
      
      should "be able to be created" do
        assert @invoice.can_create_asset_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?, "#{@invoice.errors.inspect}"
      end
      
      should "be saved successfully" do
        @invoice.save!
        assert !@invoice.new_record?
      end
      
      should "add one more asset_invoice on order" do
        before = @order.asset_invoices.count
        @invoice.save!
        assert_equal before + 1, @order.asset_invoices.count
      end
    end
  end
  
  context "In an order with a signed quote and 1 'full' signed delivery_note," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_delivery_note_for(@order)
      
      flunk "@order should have all products delivered or scheduled to perform the following" unless @order.all_is_delivered_or_scheduled?
    end
    
    teardown do
      @order = @signed_quote = @delivery_note = nil
    end
    
    context "a 'status' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_status_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
        assert @invoice.errors.invalid?(:invoice_type)
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
    
    context "a 'balance' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "be able to be created" do
        assert @invoice.can_create_balance_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?, @invoice.errors.inspect
      end
      
      should "be saved successfully" do
        @invoice.save!
        assert !@invoice.new_record?
      end
      
      should "add a balance_invoice on order" do
        @invoice.save!
        assert @order.balance_invoice
      end
    end
    
    context "with an existing 'balance' invoice, another 'balance' invoice" do
      setup do
        @balance_invoice = @order.invoices.build
        create_balance_invoice(@balance_invoice)
        flunk "@order should have a balance_invoice to perform the following" unless @order.balance_invoice
        
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @order.balance_invoice.destroy
        @balance_invoice = @invoice = nil
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_balance_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
        assert @invoice.errors.invalid?(:invoice_type)
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
  end
  
  context "In an order with a signed quote and 1 'partial' signed delivery_note," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_partial_delivery_note_for(@order)
      
      flunk "@order should NOT have all products delivered or scheduled to perform the following" if @order.all_is_delivered_or_scheduled?
    end
    
    teardown do
      @order = @signed_quote = @delivery_note = nil
    end
    
    context "a 'status' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "be able to be created" do
        assert @invoice.can_create_status_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?
      end
      
      should "be saved" do
        @invoice.save!
        assert !@invoice.new_record?
      end
      
      should "add a status_invoice on order" do
        before = @order.status_invoices.count
        @invoice.save!
        assert_equal before + 1, @order.status_invoices.count
      end
    end
    
    context "a 'balance' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_balance_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
      end
      
      should "NOT be saved" do
        assert !@invoice.save
      end
    end
    
    context "1 'status' invoice and 1 'complementary' signed delivery_note" do
      setup do
        @status_invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@status_invoice)
        @status_invoice.save!
        
        flunk "@order should have 1 status_invoice to perform the following" unless @order.status_invoices.count == 1
        
        @second_delivery_note = create_signed_complementary_delivery_note_for(@order)
      end
      
      teardown do
        @status_invoice.destroy
        @status_invoice = @second_delivery_note = nil
      end
      
      context "a 'status' invoice" do
        setup do
          @invoice = @order.invoices.build
          prepare_status_invoice_to_be_saved(@invoice)
        end
        
        teardown do
          @invoice = nil
        end
        
        should "NOT be able to be created" do
          assert !@invoice.can_create_status_invoice?
        end
        
        should "NOT be valid" do
          assert !@invoice.valid?
          assert @invoice.errors.invalid?(:invoice_type)
        end
        
        should "NOT be saved" do
          assert !@invoice.save
        end
      end
      
      context "a 'balance' invoice" do
        setup do
          @invoice = @order.invoices.build
          prepare_balance_invoice_to_be_saved(@invoice)
        end
        
        teardown do
          @invoice = nil
        end
        
        should "be able to be created" do
          assert @invoice.can_create_balance_invoice?
        end
        
        should "be valid" do
          assert @invoice.valid?
        end
        
        should "be saved" do
          @invoice.save!
          assert !@invoice.new_record?
        end
      end
    end
  end
  
  
  context "In an order with a signed quote and 1 signed delivery_note," do
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
      
      should "require at least 1 invoice_item" do
        assert @invoice.errors.invalid?(:invoice_item_ids)
        
        build_product_item_for(@invoice)
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
        
        build_due_dates_for(@invoice, 1)
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_date_ids)
      end
      
      should "build invoice_items for each associated delivery_note's items when calling 'build_invoice_items_from_associated_delivery_notes'" do
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        @invoice.build_invoice_items_from_associated_delivery_notes
        expected_value = @delivery_note.delivery_note_items.size
        
        assert_equal expected_value, @invoice.invoice_items.size
      end
      
      should "build invoice_item for a specific delivery_note when calling 'build_invoice_items_from(delivery_note)'" do
        expected_value = @order.signed_delivery_notes.first.delivery_note_items.size
        @invoice.build_invoice_items_from(@order.signed_delivery_notes.first)
        
        assert_equal expected_value, @invoice.invoice_items.size
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
      
      context "with an associated delivery_note" do
        setup do
          @invoice.delivery_note_invoices.build(:delivery_note_id => @order.signed_delivery_notes.first.id)
          
          flunk "@invoice should have 1 delivery_note_invoice to perform the following" unless @invoice.delivery_note_invoices.size == 1
          flunk "@invoice should have 0 invoice_items to perform the following" unless @invoice.invoice_items.empty?
          
          @expected_number = @invoice.delivery_note_invoices.first.delivery_note.delivery_note_items.size
        end
        
        should "build invoice_items when calling 'build_invoice_items_from_associated_delivery_notes'" do
          @invoice.build_invoice_items_from_associated_delivery_notes
          
          assert_equal @expected_number, @invoice.invoice_items.size
        end
      end
      
      context "without associated delivery_note" do
        should "NOT build invoice_items when calling 'build_invoice_items_from_associated_delivery_notes'" do
          @invoice.build_invoice_items_from_associated_delivery_notes
          
          assert_equal 0, @invoice.invoice_items.size
        end
      end
      
    end
    
    context "a 'deposit' invoice" do
      setup do
        prepare_deposit_invoice(@invoice)
        @invoice.valid?
        
        flunk "@invoice should have 0 product_items to perform the following" unless @invoice.product_items.empty?
        flunk "@invoice should have 0 free_items to perform the following" unless @invoice.free_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices to perform the following" unless @invoice.delivery_note_invoices.empty?
      end
      
      should "NOT accept product_items" do
        assert !@invoice.errors.invalid?(:product_items)
        
        build_product_item_for(@invoice)
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:product_items)
      end
      
      should "require at least 1 free_item" do
        assert @invoice.errors.invalid?(:free_items)
        
        build_free_item_for(@invoice)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:free_items)
      end
      
      should "NOT accept delivery_notes" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
        
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        flunk "@invoice should have 1 delivery_note_invoice to perform the following" unless @invoice.delivery_note_invoices.size == 1
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:delivery_note_invoices)
      end
    end
    
    [:status, :balance].each do |type|
      context "a '#{type}' invoice" do
        setup do
          send("prepare_#{type}_invoice", @invoice) #prepare_stats_invoice, prepare_balance_invoice
          @invoice.valid?
          
          flunk "@invoice should have 0 product_items to perform the following" unless @invoice.product_items.empty?
          flunk "@invoice should have 0 free_items to perform the following" unless @invoice.free_items.empty?
          flunk "@invoice should have 0 delivery_note_invoices to perform the following" unless @invoice.delivery_note_invoices.empty?
        end
        
        should "require at least 1 product_item" do
          assert @invoice.errors.invalid?(:product_items)
          
          build_product_item_for(@invoice)
          @invoice.valid?
          
          assert !@invoice.errors.invalid?(:product_items)
        end
        
        should "accept free_items" do
          assert !@invoice.errors.invalid?(:free_items)
          
          build_free_item_for(@invoice)
          
          @invoice.valid?
          assert !@invoice.errors.invalid?(:free_items)
        end
        
        should "require at least 1 delivery_note" do
          assert @invoice.errors.invalid?(:delivery_note_invoices)
          
          @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
          flunk "@invoice should have 1 delivery_note_invoice to perform the following" unless @invoice.delivery_note_invoices.size == 1
          @invoice.valid?
          
          assert !@invoice.errors.invalid?(:delivery_note_invoices)
        end
      end
    end
    
    context "an 'asset' invoice" do
      setup do
        prepare_asset_invoice(@invoice)
        @invoice.valid?
        
        flunk "@invoice should have 0 product_items to perform the following" unless @invoice.product_items.empty?
        flunk "@invoice should have 0 free_items to perform the following" unless @invoice.free_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices to perform the following" unless @invoice.delivery_note_invoices.empty?
      end
      
      should "accept product_items" do
        assert !@invoice.errors.invalid?(:product_items)
        
        build_product_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:product_items)
      end
      
      should "accept free_items" do
        assert !@invoice.errors.invalid?(:free_items)
        
        build_free_item_for(@invoice)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:free_items)
      end
      
      should "require at least 1 invoice_item (product_item)" do
        assert @invoice.errors.invalid?(:invoice_items)
        
        build_product_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:invoice_items)
      end
      
      should "require at least 1 invoice_item (free_item)" do
        assert @invoice.errors.invalid?(:invoice_items)
        
        build_free_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:invoice_items)
      end
      
      should "NOT accept delivery_notes" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
        
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        flunk "@invoice should have 1 delivery_note_invoice to perform the following" unless @invoice.delivery_note_invoices.size == 1
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:delivery_note_invoices)
      end
    end
    
    # the following tests assume a 'balance' invoice, which is the most common type of invoice,
    # and in which we can add free_item, product_items, due_dates, etc...
    context "a new and ready-to-be-saved invoice" do
      setup do
        prepare_balance_invoice_to_be_saved(@invoice)
        
        flunk "@invoice should be valid to perform the following > #{@invoice.errors.inspect}" unless @invoice.valid?
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
      
      teardown do
        @invoice.destroy
      end
      
      subject { @invoice }
      
      should_allow_values_for     :status, nil, Invoice::STATUS_CONFIRMED
      should_not_allow_values_for :status, 1, "string", Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_TOTALLY_PAID
      
      should_validate_presence_of :bill_to_address
      should_validate_presence_of :invoice_type, :with_foreign_key => :default
      
      #TODO test validates_persistence_of :order_id, :invoice_type_id
        
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
      
      #TODO test validates_persistence_of :confirmed_at, :reference, :factorised, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :contact
      
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
    context "an abandoned invoice" do
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
      quantity.times do |x|
        attributes << { :date         => Date.today + x.month,
                        :net_to_paid  => ( invoice.net_to_paid / quantity ) }
      end
      invoice.due_date_attributes=(attributes)
      
      flunk "invoice should have #{quantity} due_dates to perform the following" if invoice.due_dates.size != quantity
    end
    
    def build_free_item_for(invoice, unit_price = 0)
      before = invoice.invoice_items.size
      
      attributes = [{ :product_id   => nil,
                      :name         => "This is a free line",
                      :description  => "And this is the description of the free line",
                      :quantity     => 1,
                      :discount     => 0,
                      :unit_price   => unit_price,
                      :vat          => 8.5 }]
      invoice.invoice_item_attributes=(attributes)
      
      flunk "invoice should have one more invoice_item to perform the following" if invoice.invoice_items.size == before
    end
    
    def build_product_item_for(invoice)
      before = invoice.invoice_items.size
      
      attributes = [{ :product_id   => invoice.order.products.first.id,
                      :quantity     => 1,
                      :discount     => 0,
                      :name         => "This is a product line",
                      :description  => "And this is the description of the product line" }]
      invoice.invoice_item_attributes=(attributes)
      
      flunk "invoice should have one more invoice_item to perform the following" if invoice.invoice_items.size == before
    end
    
    def prepare_invoice(invoice, factorised = :normal)
      invoice.factorised = (factorised == :factorised)
      invoice.contact = @order.contacts.first
      invoice.bill_to_address = @order.bill_to_address
      
      return invoice
    end
    
    def prepare_deposit_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:deposit_invoice)
    end
    
    def prepare_deposit_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_deposit_invoice(invoice, factorised)
      
      build_free_item_for(invoice, 1000)
      build_due_dates_for(invoice, 1)
      
      return invoice
    end
    
    def prepare_status_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:status_invoice)
    end
    
    def prepare_status_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_status_invoice(invoice, factorised)
      flunk "invoice.order should have at least 1 signed_delivery_note to perform the following" unless invoice.order.signed_delivery_notes.count > 0
      
      invoice.delivery_note_invoices.build(:delivery_note_id => invoice.order.signed_delivery_notes.first.id)
      invoice.build_invoice_items_from_associated_delivery_notes
      
      flunk "invoice should have invoice_items to perform the following" if invoice.invoice_items.empty?
      
      build_due_dates_for(invoice, 1)
      
      return invoice
    end
    
    def prepare_balance_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:balance_invoice)
    end
    
    def prepare_balance_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_balance_invoice(invoice, factorised)
      flunk "invoice.order should have at least 1 signed_delivery_note to perform the following" unless invoice.order.signed_delivery_notes.count > 0
      
      invoice.order.signed_delivery_notes.each do |dn|
        invoice.delivery_note_invoices.build(:delivery_note_id => dn.id)
      end
      
      invoice.build_invoice_items_from_associated_delivery_notes
      flunk "invoice should have invoice_items to perform the following" if invoice.invoice_items.empty?
      
      build_due_dates_for(invoice, 1)
      
      return invoice
    end
    
    def prepare_asset_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:asset_invoice)
    end
    
    def prepare_asset_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_asset_invoice(invoice, factorised)
      
      build_free_item_for(invoice)
      build_product_item_for(invoice)
      
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
    
    # this method create a 'balance' invoice, which is the most common type of invoice,
    # and in which we can add free_item, product_items, due_dates, etc...
    #   * 'factorised' can be set at ':factorised' to create a factorised invoice
    def create_invoice(invoice, factorised = :normal)
      invoice = prepare_balance_invoice_to_be_saved(invoice, factorised)
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
    
    def create_deposit_invoice(invoice)
      invoice = prepare_deposit_invoice_to_be_saved(invoice)
      invoice.save!
      return invoice
    end
    
    def create_balance_invoice(invoice)
      invoice = prepare_balance_invoice_to_be_saved(invoice)
      invoice.save!
      return invoice
    end
    
    def update_invoice(invoice)
      invoice.contact.first_name += "string"
      invoice.bill_to_address.street_name += "string"
      invoice.invoice_items.each { |i| i.name += "string" }
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
