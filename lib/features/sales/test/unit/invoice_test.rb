require File.dirname(__FILE__) + '/../sales_test'
 
class InvoiceTest < ActiveSupport::TestCase
  #TODO test has_permissions :as_business_object, :additional_class_methods => [ :confirm, :cancel, :send_to_customer, :abandon, :factoring_pay, :due_date_pay]
  #TODO test has_address     :bill_to_address
  #TODO test has_contact     :accept_from => :customer_contacts
  
  should_belong_to :order, :factor, :invoice_type, :invoicing_actor
  
  should_have_many :invoice_items
  
  should_have_many :delivery_notes
  should_have_many :dunnings
  should_have_many :due_dates
  
  should_not_allow_mass_assignment_of :status, :reference, :confirmed_at, :cancelled_at
  
  should_journalize :attributes   => [:reference, :status, :published_on, :sended_on, :abandoned_on, :factoring_recovered_on,
                                      :factoring_balance_paid_on, :confirmed_at, :cancelled_at,
                                      :cancelled_comment, :abandoned_comment, :factoring_recovered_comment,
                                      :factor_id, :invoice_type_id, :send_invoice_method_id, :invoicing_actor_id, :invoice_contact_id,
                                      :deposit, :deposit_vat, :deposit_amount, :deposit_comment],
                    :subresources => [:bill_to_address, :invoice_items, :due_dates]
  
  context "An invoice" do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @invoice = prepare_balance_invoice(@order.invoices.build)
    end
    
    context "without invoice_items" do
      should "have a total equal to 0" do
        assert_equal 0, @invoice.total
      end
      
      should "have a total_with_taxes equal to 0" do
        assert_equal 0, @invoice.total_with_taxes
      end
      
      should "have a summon_of_taxes equal to 0" do
        assert_equal 0, @invoice.summon_of_taxes
      end
      
      should "have no tax_coefficients" do
        assert @invoice.tax_coefficients.empty?
      end
      
      should "have a number_of_pieces equal to 0" do
        assert_equal 0, @invoice.number_of_pieces
      end
    end
    
    context "with invoice_items" do
      setup do
        invoice_item = build_product_invoice_item_for(@invoice)
        flunk "@invoice should have an invoice_item with unit_price at '20000' (but was '#{invoice_item.unit_price}')" unless invoice_item.unit_price == 20000
        flunk "@invoice should have an invoice_item with vat at '19.6' (but was '#{invoice_item.vat}')" unless invoice_item.vat == 19.6
        flunk "@invoice should have an invoice_item with quantity at '1' (but was '#{invoice_item.quantity}')" unless invoice_item.quantity == 1
        
        free_invoice_item = build_free_invoice_item_for(@invoice, 1000)
        flunk "@invoice should have a free_invoice_item with unit_price at '1000' (but was '#{free_invoice_item.unit_price}'" unless free_invoice_item.unit_price == 1000
        flunk "@invoice should have a free_invoice_item with unit_price at '0' (but was '#{free_invoice_item.vat}'" unless free_invoice_item.vat == 0
        flunk "@invoice should have a free_invoice_item with quantity at '1' (but was '#{free_invoice_item.quantity}')" unless free_invoice_item.quantity == 1
      end
      
      should "have a valid total" do
        expected_value = 21000
        assert_equal expected_value, @invoice.total
      end
      
      should "have a valid total_with_taxes" do
        expected_value = ( 20000.00 * ( 1 + ( 19.6 / 100 ) ) ) + 1000
        assert_equal expected_value, @invoice.total_with_taxes
      end
      
      should "have a valid summon_of_taxes" do
        total = 21000
        total_with_taxes = ( 20000.00 * ( 1 + ( 19.6 / 100 ) ) ) + 1000
        expected_value = total_with_taxes - total
        assert_equal expected_value, @invoice.summon_of_taxes
      end
      
      should "have tax_coefficients" do
        assert_equal [19.6, 0.0], @invoice.tax_coefficients
      end
      
      should "have a valid number_of_pieces" do
        assert_equal 2, @invoice.number_of_pieces
      end
      
      context "including one which is marked to be destroyed" do
        setup do
          to_be_destroyed_item = @invoice.invoice_items.first
          to_be_destroyed_item.attributes = { :quantity => 0 }
          flunk "the invoice_item should be marked to be destroyed" unless to_be_destroyed_item.should_destroy?
          flunk "the invoice_item which is marked to be destroyed should be the one with a unit_price at 20000" unless to_be_destroyed_item.unit_price == 20000
        end
        
        should "have a valid total" do
          assert_equal 1000, @invoice.total
        end
        
        should "have a valid total_with_taxes" do
          assert_equal 1000, @invoice.total_with_taxes
        end
        
        should "have a valid summon_of_taxes" do
          assert_equal 0, @invoice.summon_of_taxes
        end
        
        should "have tax_coefficients" do
          assert_equal [0.0], @invoice.tax_coefficients
        end
        
        should "have a valid number_of_pieces" do
          assert_equal 1, @invoice.number_of_pieces
        end
      end
    end
  end
  
  context "In an order with an unfactorised customer," do
    setup do
      @order = create_default_order(false)
      @signed_quote = create_signed_quote_for(@order)
      
      flunk "@order should have an unfactorised customer" if @order.customer.factorised?
    end
    
    teardown do
      @order = @signed_quote = nil
    end
    
    context "an invoice associated to a factorisable invoice_type" do
      setup do
        @invoice = @order.invoices.build
        @invoice.invoice_type = invoice_types(:factorisable_invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "NOT be able to be 'factorised'" do
        @invoice.factor = Factor.first
        @invoice.valid?
        assert @invoice.errors.invalid?(:factor_id)
      end
      
      should "be able to be 'normal'" do
        @invoice.factor = nil
        @invoice.valid?
        assert !@invoice.errors.invalid?(:factor_id)
      end
    end
    
    context "an invoice associated to a non-factorisable invoice_type" do
      setup do
        @invoice = @order.invoices.build
        @invoice.invoice_type = invoice_types(:nonfactorisable_invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "NOT be able to be 'factorised'" do
        @invoice.factor = Factor.first
        @invoice.valid?
        assert @invoice.errors.invalid?(:factor_id)
      end
      
      should "be able to be 'normal'" do
        @invoice.factor = nil
        @invoice.valid?
        assert !@invoice.errors.invalid?(:factor_id)
      end
    end
  end
  
  context "In an order with a factorised customer," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      
      flunk "@order should have a factorised customer" unless @order.customer.factorised?
    end
    
    teardown do
      @order = @signed_quote = nil
    end
    
    context "an invoice associated to a factorisable invoice_type" do
      setup do
        @invoice = @order.invoices.build
        @invoice.invoice_type = invoice_types(:factorisable_invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "be able to be 'factorised'" do
        @invoice.factor = Factor.first
        @invoice.valid?
        assert !@invoice.errors.invalid?(:factor_id)
      end
      
      should "be able to be 'normal'" do
        @invoice.factor = nil
        @invoice.valid?
        assert !@invoice.errors.invalid?(:factor_id)
      end
    end
    
    context "an invoice associated to a non-factorisable invoice_type" do
      setup do
        @invoice = @order.invoices.build
        @invoice.invoice_type = invoice_types(:nonfactorisable_invoice)
      end
      
      teardown do
        @invoice = nil
      end
      
      should "NOT be able to be 'factorised'" do
        @invoice.factor = Factor.first
        @invoice.valid?
        assert @invoice.errors.invalid?(:factor_id)
      end
      
      should "be able to be 'normal'" do
        @invoice.factor = nil
        @invoice.valid?
        assert !@invoice.errors.invalid?(:factor_id)
      end
    end
  end
  
  context "In an order with NO signed_quote," do
    setup do
      @order = create_default_order
      2.times do
        create_default_end_product(@order)
      end
      
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
          assert @invoice.errors.invalid?(:signed_quote)
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
        flunk "@order should NOT have a deposit_invoice" if @order.deposit_invoice
        
        prepare_deposit_invoice_to_be_saved(@invoice)
      end
      
      teardown do
        @invoice = @order.invoices.build
      end
      
      should "be able to be created" do
        assert @invoice.can_create_deposit_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?, @invoice.errors.inspect
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
        flunk "@order should have a deposit_invoice" unless @order.deposit_invoice
        prepare_deposit_invoice_to_be_saved(@invoice)
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
      
      should "be able to be created" do
        assert @invoice.can_create_status_invoice?
      end
      
      #TODO write tests for this context
      context "without any invoice_item" do
        setup do
          #TODO
        end
        
        #should "NOT be valid" do
        #  assert !@invoice.valid?
        #end
        #
        #should "NOT be saved" do
        #  assert !@invoice.save
        #end
      end
      
      #TODO write tests for this context
      context "with 1 invoice_item" do
        setup do
          #TODO
        end
        
        #should "be valid" do
        #  assert @invoice.valid?
        #end
        #
        #should "be saved successfully" do
        #  assert @invoice.save!
        #end
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
      
      flunk "@order should have all products delivered or scheduled" unless @order.all_is_delivered_or_scheduled?
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
      
      #TODO write tests for this context
      context "containing all unbilled elements" do
        setup do
          #TODO
        end
        
        #should "NOT be valid" do
        #  assert !@invoice.valid?
        #  assert_contain_error @invoice, :invoice_items, "..."
        #end
        
        #should "NOT be saved" do
        #  assert !@invoice.save
        #end
      end
      
      #TODO write tests for this context
      context "containing NOT all unbilled elements" do
        setup do
          #TODO
        end
        
        #should "be valid" do
        #  assert @invoice.valid?
        #end
        
        #should "be saved successfully" do
        #  assert @invoice.save!
        #end
      end
    end
    
    context "a 'balance' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
        
        flunk "@order should have no balance_invoice" if @order.balance_invoice
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
        assert_equal @invoice, @order.balance_invoice
      end
      
      context "with at least 1 missing delivery_note among order's delivery_notes wihtout confirmed invoice" do
        setup do
          flunk "@invoice should be valid" unless @invoice.valid?
          
          @invoice.delivery_note_invoices.first.should_destroy = true
          @invoice.build_or_update_invoice_items_from_associated_delivery_notes
          
          flunk "@invoice should have at least 1 invoice_item with quantity = 0" if @invoice.invoice_items.select{ |i| i.quantity.zero? }.empty?
          @invoice.valid?
        end
        
        should "have invalid invoice_items" do
          assert_contain_error @invoice, :invoice_items, "Une facture de solde doit absolument contenir l'ensemble des éléments (produits, prestations) restant à facturer"
        end
      end
    end
    
    context "with an existing 'balance' invoice, another 'balance' invoice" do
      setup do
        @balance_invoice = @order.invoices.build
        create_balance_invoice(@balance_invoice)
        flunk "@order should have a balance_invoice" if @order.balance_invoice.nil?
        
        @invoice = @order.invoices.build
        prepare_balance_invoice(@invoice)
      end
      
      teardown do
        @balance_invoice = @invoice = nil
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
  end
  
  context "In an order with a signed quote and 1 'partial' signed delivery_note," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_partial_delivery_note_for(@order)
      
      flunk "@order should NOT have all products delivered or scheduled" if @order.all_is_delivered_or_scheduled?
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
        assert @invoice.valid?, @invoice.errors.inspect
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
    
    context "1 confirmed 'status' invoice and 1 'complementary' signed delivery_note," do
      setup do
        @status_invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@status_invoice)
        
        @status_invoice.save!
        flunk "@order should have 1 status_invoice" unless @order.status_invoices.count == 1
        
        confirm_invoice(@status_invoice)
        flunk "@status_invoice should be confirmed" unless @status_invoice.was_confirmed?
        
        @second_delivery_note = create_signed_complementary_delivery_note_for(@order)
      end
      
      teardown do
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
        
        should "be able to be created" do
          assert @invoice.can_create_status_invoice?
        end
        
        #TODO status invoice shouldn't contain all unbilled elements to be valid
        #should "be valid" do
        #  assert @invoice.valid?
        #end
        
        #TODO status invoice shouldn't contain all unbilled elements to be saved
        #should "be saved successully" do
        #  assert @invoice.save!
        #end
        
        # test validates_unique_usage_of_delivery_note
        context "associated to a delivery_note which is already billed" do
          setup do
            flunk "@delivery_note should already be billed" unless @delivery_note.invoice(true)
            flunk "@status_invoice should be associated to @delivery_note" unless @status_invoice.delivery_notes(true).include?(@delivery_note)
            
            @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
            @invoice.valid?
            
            flunk "@invoice should have 2 delivery_note_invoices" unless @invoice.delivery_note_invoices.size == 2
          end
          
          should "have invalid delivery_note_invoices" do
            assert_contain_error @invoice, :delivery_note_invoices, "Un ou plusieurs Bon de Livraison associés ont déjà été utilisé dans une autre facture. Merci de les retirer, ou d'annuler l'autre facture avant d'enregistrer celle-là."
          end
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
        
        should "be saved" do
          @invoice.save!
          assert !@invoice.new_record?
        end
      end
    end
    
    context "1 sent 'status' invoice and 1 'complementary' signed delivery_note," do
      setup do
        @status_invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@status_invoice)
        
        @status_invoice.save!
        flunk "@order should have 1 status_invoice" unless @order.status_invoices.count == 1
        
        confirm_invoice(@status_invoice)
        send_invoice(@status_invoice)
        flunk "@status_invoice should be sent" unless @status_invoice.was_sended?
        
        @second_delivery_note = create_signed_complementary_delivery_note_for(@order)
      end
      
      context "a 'status' invoice" do
        setup do
          @invoice = @order.invoices.build
          prepare_status_invoice_to_be_saved(@invoice)
        end
        
        should "be able to be created" do
          assert @invoice.can_create_status_invoice?
        end
        
        # test validates_unique_usage_of_delivery_note
        context "associated to a delivery_note which is already billed" do
          setup do
            flunk "@delivery_note should already be billed" unless @delivery_note.invoice(true)
            flunk "@status_invoice should be associated to @delivery_note" unless @status_invoice.delivery_notes(true).include?(@delivery_note)
            
            @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
            @invoice.valid?
            
            flunk "@invoice should have 2 delivery_note_invoices" unless @invoice.delivery_note_invoices.size == 2
          end
          
          should "have invalid delivery_note_invoices" do
            assert_contain_error @invoice, :delivery_note_invoices, "Un ou plusieurs Bon de Livraison associés ont déjà été utilisé dans une autre facture. Merci de les retirer, ou d'annuler l'autre facture avant d'enregistrer celle-là."
          end
        end
      end
    end
    
    #TODO run same tests when first invoice is partially_paid, totally_paid, abandoned and cancelled
    context "1 partially paid 'status' invoice and 1 'complementary' signed delivery_note," do
      #TODO
    end
    
    context "1 totally paid 'status' invoice and 1 'complementary' signed delivery_note," do
      #TODO
    end
    
    context "1 abandoned 'status' invoice and 1 'complementary' signed delivery_note," do
      #TODO
    end
    
    context "1 cancelled 'status' invoice and 1 'complementary' signed delivery_note," do
      #TODO
    end
    
    
    context "1 'complementary' 'non-signed' delivery_note," do
      setup do
        flunk "@order should have 0 invoices" unless @order.invoices.empty?
        
        @second_delivery_note = create_valid_complementary_delivery_note_for(@order)
      end
      
      teardown do
        @second_delivery_note = nil
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
          assert @invoice.valid?, @invoice.errors.inspect
        end
        
        should "be saved" do
          @invoice.save!
          assert !@invoice.new_record?
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
          assert @invoice.errors.invalid?(:invoice_type)
        end
        
        should "NOT be saved" do
          assert !@invoice.save
        end
      end
    end
  end
  
  
  context "In an order with a signed quote and 2 'partial' signed delivery_notes," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_partial_delivery_note_for(@order)
      @second_delivery_note = create_signed_complementary_delivery_note_for(@order)
      
      flunk "@order should have all products delivered" unless @order.all_is_delivered?
    end
    
    teardown do
      @order = @signed_quote = @delivery_note = @second_delivery_note = nil
    end
    
    context "a 'status' invoice associated with 1 delivery_note" do
      setup do
        @invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@invoice)
        @invoice.valid?
      end
      
      teardown do
        @invoice = nil
      end
      
      should "have valid delivery_note_invoices" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
      end
      
      should "be valid" do
        assert @invoice.valid?
      end
      
      should "be saved successfully" do
        @invoice.save!
        assert !@invoice.new_record?
      end
    end
    
    #TODO this test need to be reviewed :
    #     now, a 'status' invoice can be associated with all delivery_notes (at the condition there are other stuff to bill)
    #     but a 'status' invoice cannot be created with ALL unbilled stuff
    #
    #context "a 'status' invoice associated with 2 delivery_notes" do
    #  setup do
    #    @invoice = @order.invoices.build
    #    prepare_status_invoice_to_be_saved(@invoice)
    #    
    #    # association between the invoice and the second_delivery_note
    #    @invoice.delivery_note_invoice_attributes=( [ @delivery_note.id, @second_delivery_note.id ] )
    #    @invoice.build_or_update_invoice_items_from_associated_delivery_notes
    #    
    #    flunk "@invoice should be associated with 2 delivery_notes" unless @invoice.delivery_note_invoices.reject(&:should_destroy?).size == 2
    #    @invoice.valid?
    #  end
    #  
    #  teardown do
    #    @invoice = nil
    #  end
    #  
    #  should "NOT have valid delivery_note_invoices" do
    #    assert @invoice.errors.invalid?(:delivery_note_invoices), @invoice.errors.inspect
    #  end
    #end
    
    context "a 'balance' invoice associated with 2 delivery_notes" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
        @invoice.valid?
      end
      
      teardown do
        @invoice = nil
      end
      
      should "have valid delivery_note_invoices" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
      end
      
      should "be valid" do
        assert @invoice.valid?
      end
      
      should "be saved successfully" do
        @invoice.save!
        assert !@invoice.new_record?
      end
    end
    
    context "a 'balance' invoice associated with 1 delivery_note" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
        
        # association between the invoice and the second_delivery_note
        @invoice.delivery_note_invoice_attributes=( [ @delivery_note.id ] )
        @invoice.build_or_update_invoice_items_from_associated_delivery_notes
        
        flunk "@invoice should be associated with 1 delivery_note" unless @invoice.delivery_note_invoices.reject(&:should_destroy?).size == 1
        @invoice.valid?
      end
      
      teardown do
        @invoice = nil
      end
      
      should "have invalid invoice_items" do
        assert_contain_error @invoice, :invoice_items, "Une facture de solde doit absolument contenir l'ensemble des éléments (produits, prestations) restant à facturer"
      end
    end
  end
  
  # test validates_integrity_of_product_invoice_items
  context "In an order with a signed quote and 1 'full' signed delivery_note with discard," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_delivery_note_for(@order, true)
      
      flunk "@order should NOT have all products delivered or scheduled" if @order.all_is_delivered_or_scheduled?
    end
    
    context "a 'status' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_status_invoice_to_be_saved(@invoice)
      end
      
      should "be able to be created" do
        assert @invoice.can_create_status_invoice?
      end
      
      should "be valid" do
        assert @invoice.valid?, @invoice.errors.inspect
      end
      
      should "be saved" do
        @invoice.save!
        assert !@invoice.new_record?
      end
      
    end
    
    context "a 'balance' invoice" do
      setup do
        @invoice = @order.invoices.build
        prepare_balance_invoice_to_be_saved(@invoice)
      end
      
      should "NOT be able to be created" do
        assert !@invoice.can_create_balance_invoice?
      end
      
      should "NOT be valid" do
        assert !@invoice.valid?
        assert @invoice.errors.invalid?(:invoice_type)
      end
      
      should "be saved" do
        assert !@invoice.save
      end
    end
  end
  
  context "In an order with a signed quote and 1 signed delivery_note," do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      @delivery_note = create_signed_delivery_note_for(@order)
      
      flunk "order should have at least 2 contacts, but has #{@order.customer_contacts.count}" if @order.customer_contacts.count < 2
      
      @invoice = @order.invoices.build
    end
    
    teardown do
      @order = @signed_quote = @delivery_note = @invoice = nil
    end
    
    context "a new invoice" do
      setup do
        @invoice.valid?
      end
      
      subject{ @invoice }
      
      should_validate_presence_of :invoice_contact, :with_foreign_key => :default
      
      should "have an signed_quote" do
        assert_equal @signed_quote, @invoice.signed_quote
      end
      
      should "require at least 1 due_date" do
        assert @invoice.errors.invalid?(:due_dates)
        
        build_free_invoice_item_for(@invoice, 1900) # prepare due_dates creation by creating invoice_item first
        build_due_dates_for(@invoice, 1)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates), @invoice.due_dates.first.errors.inspect
      end
      
      should "build invoice_items for each associated delivery_note's items when calling 'build_or_update_invoice_items_from_associated_delivery_notes'" do
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        @invoice.build_or_update_invoice_items_from_associated_delivery_notes
        expected_value = @delivery_note.delivery_note_items.size
        
        assert_equal expected_value, @invoice.invoice_items.size
      end
      
      should "build invoice_item for a specific delivery_note when calling 'build_or_update_invoice_items_from(delivery_note)'" do
        expected_value = @order.signed_delivery_notes.first.delivery_note_items.size
        @invoice.build_or_update_invoice_items_from(@order.signed_delivery_notes.first)
        
        assert_equal expected_value, @invoice.invoice_items.size
      end
      
      should "build product_invoice_items when calling 'produdct_invoice_item_attributes='" do
        attributes = []
        @order.end_products.each do |p|
          attributes << { :invoiceable_id   => p.id,
                          :invoiceable_type => 'EndProduct',
                          :quantity         => p.quantity }
        end
        @invoice.product_invoice_item_attributes=(attributes)
        
        assert_equal @order.end_products.count, @invoice.invoice_items.size
      end
      
      [1,3,4].each do |x|
        should "build #{x} free_invoice_items when calling 'free_invoice_item_attributes='" do
          x.times { build_free_invoice_item_for(@invoice) }
          
          assert_equal x, @invoice.invoice_items.size
        end
        
        should "build #{x} due_dates when calling 'due_date_attributes=' with #{x} due_dates" do
          build_due_dates_for(@invoice, x)
          
          assert_equal x, @invoice.due_dates.size
        end
      end
      
      #=== validates_due_date_amounts START
      should "NOT be valid if due_date_amounts are not equal to the invoice's net_to_paid" do
        build_free_invoice_item_for(@invoice, 1000, 8.5)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 5000 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert @invoice.errors.invalid?(:due_dates)
      end
      
      should "be valid if due_date_amounts are equal to the invoice's net_to_paid" do
        build_free_invoice_item_for(@invoice, 1000, 0)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 1000 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
      end
      
      should "be valid if the difference between due_date_amounts and the invoice's net_to_paid is too small" do
        build_free_invoice_item_for(@invoice, 1000, 0)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 1000.0000006 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
      end
      #=== validates_due_date_amounts END
      
      context "with an associated delivery_note" do
        setup do
          @delivery_note = @order.signed_delivery_notes.first
          @delivery_note_invoice = @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
          
          flunk "@invoice should have 1 delivery_note_invoice" unless @invoice.delivery_note_invoices.size == 1
          flunk "@invoice should have 0 invoice_items" unless @invoice.invoice_items.empty?
          
          @expected_number = @invoice.delivery_note_invoices.first.delivery_note.delivery_note_items.size
        end
        
        teardown do
          @delivery_note = @delivery_note_invoice = @expected_number = nil
        end
        
        should "build valid invoice_items when calling 'build_or_update_invoice_items_from_associated_delivery_notes'" do
          @invoice.build_or_update_invoice_items_from_associated_delivery_notes
          
          assert_equal @expected_number, @invoice.invoice_items.reject{ |i| i.quantity.zero? }.size
        end
        
        context "set up to be destroyed (with should_destroy = true)," do
          setup do
            @invoice.build_or_update_invoice_items_from_associated_delivery_notes
            
            flunk "@invoice should have at least 1 invoice_item" unless @invoice.invoice_items.size > 0
            
            @delivery_note_invoice.should_destroy = true
          end
          
          should "mark for destroy its invoice_items when calling 'build_or_update_invoice_items_from(delivery_note, true)'" do
            @invoice.build_or_update_invoice_items_from(@delivery_note, true)
            
            assert_equal 0, @invoice.invoice_items.reject{ |i| i.quantity.zero? }.size
          end
          
          should "mark for destroy its invoice_items when calling 'build_or_update_invoice_items_from_associated_delivery_notes'" do
            @invoice.build_or_update_invoice_items_from_associated_delivery_notes
            
            assert_equal 0, @invoice.invoice_items.reject{ |i| i.quantity.zero? }.size, @invoice.invoice_items.inspect
          end
        end
      end
      
      context "without associated delivery_note" do
        should "NOT build invoice_items when calling 'build_or_update_invoice_items_from_associated_delivery_notes'" do
          @invoice.build_or_update_invoice_items_from_associated_delivery_notes
          
          assert_equal 0, @invoice.invoice_items.size
        end
      end
      
    end
    
    
    context "a new 'deposit' invoice" do
      setup do
        prepare_deposit_invoice(@invoice)
        @invoice.valid?
        
        flunk "@invoice should have 0 product_invoice_items" unless @invoice.product_invoice_items.empty?
        flunk "@invoice should have 0 free_invoice_items" unless @invoice.free_invoice_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices" unless @invoice.delivery_note_invoices.empty?
      end
      
      should "NOT require product_invoice_items" do
        assert !@invoice.errors.invalid?(:product_invoice_items)
      end
      
      should "require at least 1 free_invoice_item" do
        assert @invoice.errors.invalid?(:free_invoice_items)
      end
      
      should "NOT require delivery_notes" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
      end
      
      should "build a free_invoice_item with the correct values when calling 'build_or_update_free_invoice_item_for_deposit_invoice'" do
        add_default_deposit_attributes_on(@invoice)
        @invoice.valid?
        
        free_invoice_item = @invoice.free_invoice_items.first
        
        assert free_invoice_item
        assert_equal 1,     free_invoice_item.quantity
        assert_equal 19.6,  free_invoice_item.vat
        assert_equal @invoice.deposit_amount_without_taxes,                       free_invoice_item.unit_price
        assert_equal "Acompte de #{@invoice.deposit}% pour avance sur chantier",  free_invoice_item.name
      end
      
      should "update the free_invoice_item with the correct values when calling 'build_or_update_free_invoice_item_for_deposit_invoice' if a free_invoice_item exists already" do
        add_default_deposit_attributes_on(@invoice)
        @invoice.valid?
        flunk "@invoice should have 1 free_invoice_item" unless @invoice.free_invoice_items.size == 1
        
        free_invoice_item = @invoice.free_invoice_items.first
        
        # voluntary changes to see if the method properly change these attributes
        free_invoice_item.quantity = 10
        
        @invoice.deposit += 10
        @invoice.deposit_amount = @invoice.calculate_deposit_amount_according_to_quote_and_deposit
        @invoice.valid?
        
        free_invoice_item = @invoice.free_invoice_items.first
        
        assert free_invoice_item
        assert_equal 1,     free_invoice_item.quantity
        assert_equal 19.6,  free_invoice_item.vat
        assert_equal @invoice.deposit_amount_without_taxes,                       free_invoice_item.unit_price
        assert_equal "Acompte de #{@invoice.deposit}% pour avance sur chantier",  free_invoice_item.name
      end
      
      should "automatically build a free_invoice_item if all required attributes are present" do
        add_default_deposit_attributes_on(@invoice)
        @invoice.valid?
        
        assert_equal 1, @invoice.free_invoice_items.size
      end
      
      should "not automatically build a free_invoice_item if the required attributes are missing" do
        @invoice.valid?
        assert_equal 0, @invoice.free_invoice_items.size
      end
      
      should "not automatically build a free_invoice_item if 'deposit' is missing" do
        @invoice.deposit_amount  = @invoice.net_to_paid * 0.4
        @invoice.deposit_vat     = 19.6
        @invoice.valid?
        
        assert_equal 0, @invoice.free_invoice_items.size
      end
      
      should "not automatically build a free_invoice_item if 'deposit_amount' is missing" do
        @invoice.deposit      = 40
        @invoice.deposit_vat  = 19.6
        @invoice.valid?
        
        assert_equal 0, @invoice.free_invoice_items.size
      end
      
      should "not automatically build a free_invoice_item if 'deposit_vat' is missing" do
        @invoice.deposit         = 40
        @invoice.deposit_amount  = @invoice.net_to_paid * 0.4
        @invoice.valid?
        
        assert_equal 0, @invoice.free_invoice_items.size
      end
    end
    
    
    context "a ready-to-be-saved 'deposit' invoice" do
      setup do
        prepare_deposit_invoice_to_be_saved(@invoice)
        @invoice.valid?
        
        flunk "@invoice should have 0 product_invoice_items" unless @invoice.product_invoice_items.empty?
        flunk "@invoice should have at least 1 free_invoice_item" if @invoice.free_invoice_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices" unless @invoice.delivery_note_invoices.empty?
      end
      
      subject{ @invoice }
      
      should_validate_numericality_of :deposit, :deposit_amount, :deposit_vat
      
      should "NOT accept product_invoice_items" do
        build_product_invoice_item_for(@invoice)
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:product_invoice_items)
      end
      
      should "have valid free_invoice_items" do
        assert !@invoice.errors.invalid?(:free_invoice_items)
      end
      
      should "NOT accept delivery_notes" do
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        flunk "@invoice should have 1 delivery_note_invoice" unless @invoice.delivery_note_invoices.size == 1
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:delivery_note_invoices)
      end
    end
    
    
    context "a 'status' invoice" do
      # nothing to do here, status invoice cannot be created in this context
    end
    
    
    context "a new 'balance' invoice" do
      setup do
        prepare_balance_invoice(@invoice)
        
        flunk "@invoice should have 0 product_invoice_items" unless @invoice.product_invoice_items.empty?
        flunk "@invoice should have 0 free_invoice_items" unless @invoice.free_invoice_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices" unless @invoice.delivery_note_invoices.empty?
        
        @invoice.valid?
      end
      
      should "require at least 1 product_invoice_item" do
        assert @invoice.errors.invalid?(:product_invoice_items)
      end
      
      should "NOT require free_invoice_items" do
        assert !@invoice.errors.invalid?(:free_invoice_items)
      end
      
      should "require all unbilled elements" do
        assert_contain_error @invoice, :invoice_items, "Une facture de solde doit absolument contenir l'ensemble des éléments (produits, prestations) restant à facturer"
      end
    end
    
    context "a ready-to-be-saved 'balance' invoice" do
      setup do
        prepare_balance_invoice_to_be_saved(@invoice)
        
        flunk "@invoice should have at least 1 product_invoice_items" if @invoice.product_invoice_items.empty?
        flunk "@invoice should have 0 free_invoice_items" unless @invoice.free_invoice_items.empty?
        flunk "@invoice should have at least 1 delivery_note_invoices" if @invoice.delivery_note_invoices.empty?
        
        @invoice.valid?
      end
      
      should "have valid product_invoice_items" do
        assert !@invoice.errors.invalid?(:product_invoice_items)
      end
      
      should "accept free_invoice_items" do
        assert !@invoice.errors.invalid?(:free_invoice_items)
        
        build_free_invoice_item_for(@invoice)
        flunk "@invoice should have at least 1 free_invoice_item" if @invoice.free_invoice_items.empty?
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:free_invoice_items)
      end
      
      should "have valid delivery_note_invoices" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices), @invoice.errors.inspect
      end
    end
    
    
    context "an 'asset' invoice" do
      setup do
        prepare_asset_invoice(@invoice)
        @invoice.valid?
        
        flunk "@invoice should have 0 product_invoice_items" unless @invoice.product_invoice_items.empty?
        flunk "@invoice should have 0 free_invoice_items" unless @invoice.free_invoice_items.empty?
        flunk "@invoice should have 0 delivery_note_invoices" unless @invoice.delivery_note_invoices.empty?
      end
      
      should "accept product_invoice_items" do
        assert !@invoice.errors.invalid?(:product_invoice_items)
        
        build_product_invoice_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:product_invoice_items)
      end
      
      should "accept free_invoice_items" do
        assert !@invoice.errors.invalid?(:free_invoice_items)
        
        build_free_invoice_item_for(@invoice)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:free_invoice_items)
      end
      
      should "require at least 1 invoice_item (product_invoice_item)" do
        assert @invoice.errors.invalid?(:invoice_items)
        
        build_product_invoice_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:invoice_items)
      end
      
      should "require at least 1 invoice_item (free_invoice_item)" do
        assert @invoice.errors.invalid?(:invoice_items)
        
        build_free_invoice_item_for(@invoice)
        @invoice.valid?
        
        assert !@invoice.errors.invalid?(:invoice_items)
      end
      
      should "NOT accept delivery_notes" do
        assert !@invoice.errors.invalid?(:delivery_note_invoices)
        
        @invoice.delivery_note_invoices.build(:delivery_note_id => @delivery_note.id)
        flunk "@invoice should have 1 delivery_note_invoice" unless @invoice.delivery_note_invoices.size == 1
        @invoice.valid?
        
        assert @invoice.errors.invalid?(:delivery_note_invoices)
      end
    end
    
    # the following tests assume a 'balance' invoice, which is the most common type of invoice,
    # and in which we can add free_invoice_item, product_invoice_items, due_dates, etc...
    context "a new and ready-to-be-saved invoice" do
      setup do
        prepare_balance_invoice_to_be_saved(@invoice)
        
        flunk "@invoice should be valid > #{@invoice.errors.inspect}" unless @invoice.valid?
      end
      
      teardown do
        @invoice = nil
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, nil
      should_not_allow_values_for :status, 1, "string", Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      should_validate_presence_of :bill_to_address
      should_validate_presence_of :invoice_type, :invoicing_actor, :invoice_contact, :with_foreign_key => :default
      
      should "save invoice_items after saving itself" do
        @invoice.save!
        
        assert_equal @order.end_products.count, @invoice.invoice_items.count
        assert_equal 0, @invoice.free_invoice_items.count
        assert_equal @order.end_products.count, @invoice.product_invoice_items.count
      end
      
      [1,3,4].each do |x|
        should "save #{x} free_invoice_items after saving itself" do
          x.times { build_free_invoice_item_for(@invoice) }
          @invoice.save!
          
          assert_equal @order.end_products.count + x, @invoice.invoice_items.count
          assert_equal x, @invoice.free_invoice_items.count
          assert_equal @order.end_products.count, @invoice.product_invoice_items.count
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
      
      should_allow_values_for     :status, nil, Invoice::STATUS_CONFIRMED
      should_not_allow_values_for :status, 1, "string", Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
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
      
      #=== validates_due_date_amounts START
      should "NOT be valid if due_date_amounts are not equal to the invoice's net_to_paid" do
        build_free_invoice_item_for(@invoice, 1000, 8.5)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 5000 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert @invoice.errors.invalid?(:due_dates)
      end
      
      should "be valid if due_date_amounts are equal to the invoice's net_to_paid" do
        build_free_invoice_item_for(@invoice, 1000, 0)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 1000 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
      end
      
      should "be valid if the difference between due_date_amounts and the invoice's net_to_paid is too small" do
        build_free_invoice_item_for(@invoice, 1000, 0)
        
        attributes = [{ :date         => Date.today + 1.month,
                        :net_to_paid  => ( 1000.0000006 ) }]
        @invoice.due_date_attributes=(attributes)
        
        @invoice.valid?
        assert !@invoice.errors.invalid?(:due_dates)
      end
      #=== validates_due_date_amounts END
      
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
        assert @invoice.can_be_deleted?
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
      
      should "NOT be able to be factoring_balance_paid" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      #should "NOT be factoring_balance_paid" do
      #  factoring_balance_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_balance_paid?
      #end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
      context "which is going to be CONFIRMED" do
        setup do
          @invoice.status = Invoice::STATUS_CONFIRMED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :confirmed_at, :published_on, :reference
        #TODO test validates_date :confirmed_at, :on_or_after => :created_at, :on_or_after_message => "ne doit pas être AVANT la date de création de la facture&#160;(%s)"
        #TODO test validates_date :published_at, :on_or_after => Proc.new{ |i| i.signed_quote.signed_on }, :on_or_after_message => "ne doit pas être AVANT la date de signature du devis&#160;(%s)"
      end
      
      context "which is CONFIRMED without published_on" do
        setup do
          @invoice.published_on = nil
          flunk "@invoice.pulished_on should be nil" if @invoice.published_on
          
          @invoice.confirm
          flunk "@invoice should be confirmed" unless @invoice.confirmed_at_was
        end
        
        should "have a published_on automatically set at today" do
          assert_equal Date.today, @invoice.published_on_was
        end
      end
      
      context "which is CONFIRMED with published_on" do
        setup do
          @invoice.published_on = Date.tomorrow
          flunk "@invoice.pulished_on should be at tomorrow" unless @invoice.published_on == Date.tomorrow
          
          @invoice.due_dates.each{ |dd| dd.date = Date.tomorrow } # because due dates cannot be before the invoice's published date
          
          flunk "@invoice should be confirmed" unless @invoice.confirm
        end
        
        should "have a published_on set at the given date" do
          assert_equal Date.tomorrow, @invoice.published_on_was
        end
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
        prepare_confirmed_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      #TODO test validates_persistence_of :confirmed_at, :published_on, :reference, :factor_id, :bill_to_address, :invoice_type_id, :invoice_items, :due_dates, :invoicing_actor, :invoice_contact
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_deleted?
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
      
      should "NOT be able to be factoring_balance_paid" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      #should "NOT be factoring_balance_paid" do
      #  factoring_balance_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_balance_paid?
      #end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
      context "which is going to be CANCELLED" do
        setup do
          @invoice.status = Invoice::STATUS_CANCELLED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :cancelled_at, :cancelled_comment
        
        #TODO test validates_date :cancelled_at, :on_or_after => :published_on, :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
      end
      
      context "which is going to be SENDED" do
        setup do
          @invoice.status = Invoice::STATUS_SENDED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :sended_on
        should_validate_presence_of :send_invoice_method, :with_foreign_key => :default
        
        #TODO test validates_date :sended_on, :on_or_after => :published_on, :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)"
      end
    end
    
    # tests for CANCELLED invoice
    context "a cancelled invoice" do
      setup do
        prepare_cancelled_invoice(@invoice)
      end
      
      #TODO test validates_persistence_of :status, :cancelled_at, :cancelled_comment
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_deleted?
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
      
      should "NOT be able to be factoring_balance_paid" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      #should "NOT be factoring_balance_paid" do
      #  factoring_balance_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_balance_paid?
      #end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
    end
    
    # tests for SENDED and NORMAL invoice
    [1, 2].each do |number_of_unpaid_due_dates|
      context "a sended and normal invoice with #{number_of_unpaid_due_dates} unpaid_due_dates" do
        setup do
          prepare_sended_invoice(@invoice, nil, number_of_unpaid_due_dates)
        end
        
        #TODO test validates_persistence_of :sended_on
        
        should "NOT be able to be edited" do
          assert !@invoice.can_be_edited?
        end
        
        should "NOT be edited" do
          assert_invoice_cannot_be_edited(@invoice)
        end
        
        should "NOT be able to be destroyed" do
          assert !@invoice.can_be_deleted?
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
        
        should "NOT be able to be factoring_balance_paid" do
          assert !@invoice.can_be_factoring_balance_paid?
        end
        
        #should "NOT be factoring_balance_paid" do
        #  factoring_balance_pay_invoice(@invoice)
        #  assert !@invoice.was_factoring_balance_paid?
        #end
        
        context "which is going to be CANCELLED" do
          setup do
            @invoice.status = Invoice::STATUS_CANCELLED
          end
          
          subject { @invoice }
          
          should_validate_presence_of :cancelled_at, :cancelled_comment
          
          #TODO test validates_date :cancelled_at, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
        end
        
        context "which is going to be ABANDONED" do
          setup do
            @invoice.status = Invoice::STATUS_ABANDONED
          end
          
          subject { @invoice }
          
          should_validate_presence_of :abandoned_on, :abandoned_comment
          
          #TODO test validates_date :abandoned_on, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
        end
        
      end
    end
    
    context "a sended and normal invoice with 1 unpaid_due_date" do
      setup do
        prepare_sended_invoice(@invoice, nil, 1)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_CANCELLED, Invoice::STATUS_ABANDONED, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_DUE_DATE_PAID
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "be able to be totally_paid" do
        assert @invoice.can_be_totally_paid?
      end
      
      should "be totally_paid" do
        totally_pay_invoice(@invoice)
        assert @invoice.was_totally_paid?
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    context "a sended and normal invoice with 2 unpaid_due_dates" do
      setup do
        prepare_sended_invoice(@invoice, nil, 2)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_CANCELLED, Invoice::STATUS_ABANDONED, Invoice::STATUS_DUE_DATE_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      should "be able to be due_date_paid" do
        assert @invoice.can_be_due_date_paid?
      end
      
      should "be due_date_paid" do
        due_date_pay_invoice(@invoice)
        assert @invoice.was_due_date_paid?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
      context "which is going to be DUE_DATE_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_DUE_DATE_PAID
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
      
      should_allow_values_for :status, Invoice::STATUS_CANCELLED, Invoice::STATUS_FACTORING_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID, Invoice::STATUS_ABANDONED
      
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
      
      should "NOT be able to be factoring_balance_paid" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      #should "NOT be factoring_balance_paid" do
      #  factoring_balance_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_balance_paid?
      #end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
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
    
    # tests for ABANDONED and NORMAL invoice
    context "an abandoned and normal invoice" do
      setup do
        prepare_abandoned_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID
      
      #TODO test validates_persistence_of :abandoned_on, :abandoned_comment
      
      #TODO all tests for abandoned invoice here
      
      context "which is going to be DUE_DATE_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_DUE_DATE_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
      
      context "which is going to be TOTALLY_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_TOTALLY_PAID
        end
        
        subject { @invoice }
        
        #TODO
      end
    end
    
    # tests for ABANDONED and FACTORISED invoice
    context "an abandoned and factorised invoice" do
      setup do
        prepare_abandoned_invoice(@invoice, :factorised)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_FACTORING_BALANCE_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      #TODO test validates_persistence_of :abandoned_on, :abandoned_comment
      
      #TODO all tests for abandoned invoice here
      
      context "which is going to be FACTORING_BALANCE_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_BALANCE_PAID
        end
        
        #TODO is this test right ?
        should "validate presence of factoring_payment" do
          @invoice.valid?
          @invoice.errors.invalid?(:factoring_payment)
        end
      end
    end
    
    # tests for FACTORING_PAID invoice
    context "a factoring_paid invoice" do
      setup do
        prepare_factoring_paid_invoice(@invoice)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_ABANDONED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_deleted?
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
      
      should "be able to be factoring_balance_paid" do
        assert @invoice.can_be_factoring_balance_paid?
      end
      
      should "be factoring_balance_paid" do
        factoring_balance_pay_invoice(@invoice)
        assert @invoice.was_factoring_balance_paid?
      end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
      context "which is going to be FACTORING_RECOVERED" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_RECOVERED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :factoring_recovered_on, :factoring_recovered_comment
        
        #TODO test validates_date :factoring_recovered_on, :on_or_after => :factoring_paid_on, :on_or_after_message => "ne doit pas être AVANT la date de réglement par le factor de la facture&#160;(%s)"
      end
      
      context "which is going to be FACTORING_BALANCE_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_BALANCE_PAID
        end
        
        subject { @invoice }
        
        should_validate_presence_of :factoring_balance_paid_on
        
        #TODO test validates_date :factoring_balance_paid_on, :on_or_after => :factoring_paid_on, :on_or_after_message => "ne doit pas être AVANT la date de réglement par le factor de la facture&#160;(%s)"
      end
    end
    
    # tests for FACTORING_RECOVERED invoice
    context "a factoring_recovered invoice" do
      setup do
        prepare_factoring_recovered_invoice(@invoice)
      end
      
      subject { @invoice }
      
      #TODO test persistence_of :factoring_recovered_on, :factoring_recovered_comment
      
      should_allow_values_for :status, Invoice::STATUS_ABANDONED, Invoice::STATUS_FACTORING_BALANCE_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_DUE_DATE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      should "NOT be able to be edited" do
        assert !@invoice.can_be_edited?
      end
      
      should "NOT be edited" do
        assert_invoice_cannot_be_edited(@invoice)
      end
      
      should "NOT be able to be destroyed" do
        assert !@invoice.can_be_deleted?
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
      
      should "be able to be factoring_balance_paid" do
        assert @invoice.can_be_factoring_balance_paid?
      end
      
      should "be factoring_balance_paid" do
        factoring_balance_pay_invoice(@invoice)
        assert @invoice.was_factoring_balance_paid?
      end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
      
      context "which is going to be ABANDONED" do
        setup do
          @invoice.status = Invoice::STATUS_ABANDONED
        end
        
        subject { @invoice }
        
        should_validate_presence_of :abandoned_on, :abandoned_comment
        
        #TODO test validates_date :abandoned_on, :on_or_after => :sended_on, :on_or_after_message => "ne doit pas être AVANT la date d'envoi de la facture&#160;(%s)"
      end
      
      context "which is going to be FACTORING_BALANCE_PAID" do
        setup do
          @invoice.status = Invoice::STATUS_FACTORING_BALANCE_PAID
        end
        
        subject { @invoice }
        
        should_validate_presence_of :factoring_balance_paid_on
        
        #TODO test validates_date :factoring_balance_paid_on, :on_or_after => :factoring_recovered_on, :on_or_after_message => "ne doit pas être AVANT la date de définancement de la facture&#160;(%s)"
      end
    end
    
    # tests for FACTORING_BALANCE_PAID invoice
    context "a factoring_balance_paid invoice" do
      setup do
        prepare_factoring_balance_paid_invoice(@invoice)
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
        assert !@invoice.can_be_deleted?
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
      
      should "NOT be able to be factoring_balance_paid 'again'" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      #should "NOT be factoring_balance_paid" do
      #  factoring_balance_pay_invoice(@invoice)
      #  assert !@invoice.was_factoring_balance_paid?
      #end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert @invoice.was_totally_paid?
      #end
    end
    
    # tests for DUE_DATE_PAID invoice
    [1, 2].each do |number_of_unpaid_due_dates|
      context "a due_date_paid invoice with #{number_of_unpaid_due_dates} remaining unpaid_due_dates" do
        setup do
          prepare_due_date_paid_invoice(@invoice, number_of_unpaid_due_dates + 1)
        end
        
        should "NOT be able to be edited" do
          assert !@invoice.can_be_edited?
        end
        
        should "NOT be edited" do
          assert_invoice_cannot_be_edited(@invoice)
        end
        
        should "NOT be able to be destroyed" do
          assert !@invoice.can_be_deleted?
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
        
        should "NOT be able to be factoring_recovered" do
          assert !@invoice.can_be_factoring_recovered?
        end
        
        should "NOT be factoring_recovered" do
          factoring_recover_invoice(@invoice)
          assert !@invoice.was_factoring_recovered?
        end
        
        should "NOT be able to be factoring_balance_paid" do
          assert !@invoice.can_be_factoring_balance_paid?
        end
        
        #should "NOT be factoring_balance_paid" do
        #  factoring_balance_pay_invoice(@invoice)
        #  assert !@invoice.was_factoring_balance_paid?
        #end
      end
    end
    
    context "a due_date_paid invoice with 1 remaining unpaid_due_dates" do
      setup do
        prepare_due_date_paid_invoice(@invoice, 2)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_ABANDONED, Invoice::STATUS_TOTALLY_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_DUE_DATE_PAID
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "be able to be totally_paid" do
        assert @invoice.can_be_totally_paid?
      end
      
      should "be totally_paid" do
        totally_pay_invoice(@invoice)
        assert @invoice.was_totally_paid?
      end
    end
    
    context "a due_date_paid invoice with 2 remaining unpaid_due_dates" do
      setup do
        prepare_due_date_paid_invoice(@invoice, 3)
      end
      
      subject { @invoice }
      
      should_allow_values_for :status, Invoice::STATUS_ABANDONED, Invoice::STATUS_DUE_DATE_PAID
      should_not_allow_values_for :status, 1, "string", nil, Invoice::STATUS_CONFIRMED, Invoice::STATUS_CANCELLED, Invoice::STATUS_SENDED, Invoice::STATUS_FACTORING_PAID, Invoice::STATUS_FACTORING_RECOVERED, Invoice::STATUS_FACTORING_BALANCE_PAID, Invoice::STATUS_TOTALLY_PAID
      
      should "be able to be due_date_paid" do
        assert @invoice.can_be_due_date_paid?
      end
      
      should "be due_date_paid" do
        due_date_pay_invoice(@invoice)
        assert @invoice.was_due_date_paid?
      end
      
      should "NOT be able to be totally_paid" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "NOT be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert !@invoice.was_totally_paid?
      #end
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
        assert !@invoice.can_be_deleted?
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
      
      should "NOT be able to be factoring_balance_paid" do
        assert !@invoice.can_be_factoring_balance_paid?
      end
      
      should "NOT be factoring_balance_paid" do
        factoring_balance_pay_invoice(@invoice)
        assert !@invoice.was_factoring_balance_paid?
      end
      
      should "NOT be able to be due_date_paid" do
        assert !@invoice.can_be_due_date_paid?
      end
      
      #should "NOT be due_date_paid" do
      #  due_date_pay_invoice(@invoice)
      #  assert !@invoice.was_due_date_paid?
      #end
      
      should "NOT be able to be totally_paid 'again'" do
        assert !@invoice.can_be_totally_paid?
      end
      
      #should "be totally_paid" do
      #  totally_pay_invoice(@invoice)
      #  assert @invoice.was_totally_paid?
      #end
    end
  end
  
  context "Thanks to 'has_reference', an invoice" do
    setup do
      @reference_owner       = create_default_invoice
      @other_reference_owner = create_default_invoice
    end
    
    include HasReferenceTest
  end
  
  context "Thanks to 'has_contact', an invoice" do
    setup do
      @contact_owner = create_default_invoice
      @contact_keys = [ :invoice_contact ]
    end
    
    subject { @contact_owner }
          
    should_belong_to :invoice_contact
    
    include HasContactTest
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
      
      flunk "invoice should have #{quantity} due_dates" if invoice.due_dates.size != quantity
    end
    
    def build_free_invoice_item_for(invoice, unit_price = 0, vat = 0)
      before = invoice.invoice_items.size
      
      attributes = [{ :invoiceable_id => nil,
                      :name           => "This is a free line",
                      :description    => "And this is the description of the free line",
                      :quantity       => 1,
                      :unit_price     => unit_price,
                      :vat            => vat }]
      invoice.free_invoice_item_attributes=(attributes)
      
      flunk "invoice should have one more invoice_item" if invoice.invoice_items.size == before
      return invoice.invoice_items.last
    end
    
    def build_product_invoice_item_for(invoice)
      before = invoice.invoice_items.size
      
      attributes = [{ :invoiceable_id   => invoice.order.end_products.first.id,
                      :invoiceable_type => 'EndProduct',
                      :quantity         => 1,
                      :name             => "This is a product line",
                      :description      => "And this is the description of the product line" }]
      invoice.product_invoice_item_attributes=(attributes)
      
      flunk "invoice should have one more invoice_item" if invoice.invoice_items.size == before
      return invoice.invoice_items.last
    end
    
    def prepare_invoice(invoice, factorised = :normal)
      invoice.factor              = Factor.first if factorised == :factorised
      invoice.invoicing_actor_id  = employees(:john_doe).id
      invoice.invoice_contact_id  = @order.all_contacts.first.id
      invoice.bill_to_address     = @order.bill_to_address
      invoice.published_on        = Date.today
      return invoice
    end
    
    def prepare_deposit_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:deposit_invoice)
      return invoice
    end
    
    def prepare_deposit_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_deposit_invoice(invoice, factorised)
      
      add_default_deposit_attributes_on(invoice)
      invoice.build_or_update_free_invoice_item_for_deposit_invoice
      
      build_due_dates_for(invoice, 1)
      return invoice
    end
    
    def add_default_deposit_attributes_on(invoice)
      invoice.deposit         = 40
      invoice.deposit_amount  = invoice.signed_quote.net_to_paid * 0.4
      invoice.deposit_vat     = 19.6
      invoice.deposit_comment = "This is a deposit invoice."
    end
    
    def prepare_status_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:status_invoice)
      return invoice
    end
    
    def prepare_status_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_status_invoice(invoice, factorised)
      flunk "invoice.order should have at least 1 signed_delivery_note" unless invoice.order.signed_delivery_notes.count > 0
      
      invoice.delivery_note_invoices.build(:delivery_note_id => invoice.order.signed_delivery_notes.first.id)
      invoice.build_or_update_invoice_items_from_associated_delivery_notes
      
      flunk "invoice should have invoice_items" if invoice.invoice_items.empty?
      
      build_due_dates_for(invoice, 1)
      return invoice
    end
    
    def prepare_balance_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:balance_invoice)
      return invoice
    end
    
    def prepare_balance_invoice_to_be_saved(invoice, factorised = :normal, number_of_due_dates = 1)
      prepare_balance_invoice(invoice, factorised)
      flunk "invoice.order should have at least 1 signed_delivery_note" unless invoice.order.signed_delivery_notes.count > 0
      flunk "invoice.order should have at least 1 unbilled signed_delivery_note" if invoice.order.all_signed_delivery_notes_have_confirmed_invoice?
      
      invoice.order.signed_delivery_notes.reject(&:billed?).each do |dn|
        invoice.delivery_note_invoices.build(:delivery_note_id => dn.id)
      end
      
      invoice.build_or_update_invoice_items_from_associated_delivery_notes
      flunk "invoice should have invoice_items" if invoice.invoice_items.empty?
      
      build_due_dates_for(invoice, number_of_due_dates)
      return invoice
    end
    
    def prepare_asset_invoice(invoice, factorised = :normal)
      invoice = prepare_invoice(invoice, factorised)
      invoice.invoice_type = invoice_types(:asset_invoice)
      return invoice
    end
    
    def prepare_asset_invoice_to_be_saved(invoice, factorised = :normal)
      prepare_asset_invoice(invoice, factorised)
      
      build_free_invoice_item_for(invoice)
      build_product_invoice_item_for(invoice)
      
      build_due_dates_for(invoice, 1)
      return invoice
    end
    
    # this method create a 'balance' invoice, which is the most common type of invoice,
    # and in which we can add free_invoice_item, product_invoice_items, due_dates, etc...
    #   * 'factorised' can be set at ':factorised' to create a factorised invoice
    def create_invoice(invoice, factorised = :normal, number_of_due_dates = 1)
      invoice = prepare_balance_invoice_to_be_saved(invoice, factorised, number_of_due_dates)
      invoice.save!
      return invoice
    end
    
    def prepare_confirmed_invoice(invoice, factorised = :normal, number_of_due_dates = 1)
      create_invoice(invoice, factorised, number_of_due_dates)
      invoice = confirm_invoice(invoice)
      flunk "invoice should be confirmed > #{invoice.status} : #{invoice.status_was}" unless invoice.was_confirmed?
      return invoice
    end
    
    def prepare_cancelled_invoice(invoice)
      prepare_confirmed_invoice(invoice)
      invoice = cancel_invoice(invoice)
      flunk "invoice should be cancelled" unless invoice.was_cancelled?
      
      return invoice
    end
    
    def prepare_sended_invoice(invoice, factorised = :normal, number_of_due_dates = 1)
      prepare_confirmed_invoice(invoice, factorised, number_of_due_dates)
      invoice = send_invoice(invoice)
      flunk "invoice should be sended #{invoice.errors.inspect}" unless invoice.was_sended?
      return invoice
    end
    
    def prepare_abandoned_invoice(invoice, factorised = :normal, number_of_due_dates = 1)
      if factorised == :normal
        prepare_sended_invoice(invoice, :normal, number_of_due_dates)
      elsif factorised == :factorised
        prepare_factoring_recovered_invoice(invoice)
      end
      invoice = abandon_invoice(invoice)
      flunk "invoice should be abandoned > #{invoice.errors.inspect}" unless invoice.was_abandoned?
      return invoice
    end
    
    def prepare_factoring_paid_invoice(invoice)
      prepare_sended_invoice(invoice, :factorised, 1)
      invoice = factoring_pay_invoice(invoice)
      flunk "invoice should be factoring_paid" unless invoice.was_factoring_paid?
      return invoice
    end
    
    def prepare_factoring_recovered_invoice(invoice)
      prepare_factoring_paid_invoice(invoice)
      invoice = factoring_recover_invoice(invoice)
      flunk "invoice should be factoring_recovered" unless invoice.was_factoring_recovered?
      return invoice
    end
    
    def prepare_factoring_balance_paid_invoice(invoice)
      prepare_factoring_paid_invoice(invoice)
      invoice = factoring_balance_pay_invoice(invoice)
      flunk "invoice should be factoring_balance_paid" unless invoice.was_factoring_balance_paid?
      return invoice
    end
    
    def prepare_due_date_paid_invoice(invoice, number_of_due_dates = 2)
      prepare_sended_invoice(invoice, :normal, number_of_due_dates)
      invoice = due_date_pay_invoice(invoice)
      flunk "invoice should be due_date_paid" unless invoice.was_due_date_paid?
      return invoice
    end
    
    def prepare_totally_paid_invoice(invoice)
      prepare_due_date_paid_invoice(invoice)
      invoice = totally_pay_invoice(invoice)
      flunk "invoice should be totally_paid" unless invoice.was_totally_paid?
      return invoice
    end
    
    def confirm_invoice(invoice)
      invoice.confirm
      return invoice
    end
    
    def cancel_invoice(invoice)
      attributes = { :cancelled_comment => "this invoice is cancelled now" }
      invoice.cancel(attributes)
      return invoice
    end
    
    def send_invoice(invoice)
      attributes = { :sended_on => Date.today, :send_invoice_method_id => send_invoice_methods(:fax).id }
      invoice.send_to_customer(attributes)
      return invoice
    end
    
    def abandon_invoice(invoice)
      attributes = { :abandoned_comment => "this invoice is abandoned now" }
      invoice.abandon(attributes)
      return invoice
    end
    
    def factoring_pay_invoice(invoice)
      amount = invoice.net_to_paid * 0.9 # 90% of the total
      attributes = { :due_date_to_pay => { :id => invoice.due_dates.first.id,
                                           :payment_attributes => [ { :paid_on  => Date.today,
                                                                      :amount   => amount } ] } }
      invoice.factoring_pay(attributes)
      return invoice
    end
    
    def factoring_recover_invoice(invoice)
      attributes = { :factoring_recovered_on => Date.today, :factoring_recovered_comment => "this invoice is recovered now" }
      invoice.factoring_recover(attributes)
      return invoice
    end
    
    def factoring_balance_pay_invoice(invoice)
      attributes = { :factoring_balance_paid_on => Date.today }
      invoice.factoring_balance_pay(attributes)
      return invoice
    end
    
    def due_date_pay_invoice(invoice)
      flunk "invoice should have at least 2 unpaid due_dates, but has #{invoice.unpaid_due_dates.count}" unless invoice.unpaid_due_dates.count >= 2
      
      due_date = invoice.upcoming_due_date
      attributes = { :due_date_to_pay => { :id => due_date.id,
                                           :payment_attributes => [ { :paid_on           => Date.today,
                                                                      :amount            => due_date.net_to_paid,
                                                                      :payment_method_id => payment_methods(:cash).id } ] } }
      invoice.due_date_pay(attributes)
      return invoice
    end
    
    def totally_pay_invoice(invoice)
      flunk "invoice should have only 1 unpaid due_date, but has #{invoice.unpaid_due_dates.count}" unless invoice.unpaid_due_dates.count == 1
      
      due_date = invoice.upcoming_due_date
      attributes = { :due_date_to_pay => { :id => due_date.id,
                                           :payment_attributes => [ { :paid_on           => Date.today,
                                                                      :amount            => due_date.net_to_paid,
                                                                      :payment_method_id => payment_methods(:cash).id } ] } }
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
      invoice.invoice_contact_id = ( invoice.order.customer_contacts - [invoice.invoice_contact] ).first.id
      invoice.bill_to_address.street_name += "string"
      invoice.invoice_items.each { |i| i.name += "string" }
      invoice.due_dates.each { |d| d.date += 1.week }
      return invoice
    end
    
    def assert_invoice_can_be_edited(invoice)
      before_contact_id                 = invoice.invoice_contact_id
      before_bill_to_address_attributes = invoice.bill_to_address.attributes
      before_invoice_item_attributes    = invoice.invoice_items.first.attributes
      before_due_date_attributes        = invoice.due_dates.first.attributes
      
      update_invoice(invoice)
      
      assert invoice.valid?, "#{invoice.errors.inspect}"
      assert !invoice.errors.invalid?(:invoice_contact_id)
      assert !invoice.errors.invalid?(:bill_to_address)
      assert !invoice.errors.invalid?(:invoice_items)
      assert !invoice.errors.invalid?(:due_dates)
      
      invoice.save!
      
      assert_not_equal before_contact_id,                 invoice.invoice_contact_id
      assert_not_equal before_bill_to_address_attributes, invoice.bill_to_address.attributes
      assert_not_equal before_invoice_item_attributes,    invoice.invoice_items.first.attributes
      assert_not_equal before_due_date_attributes,        invoice.due_dates.first.attributes
    end
    
    def assert_invoice_cannot_be_edited(invoice)
      update_invoice(invoice)
      
      assert !invoice.valid?
      assert invoice.errors.invalid?(:invoice_contact_id), "#{invoice.errors.inspect}"
      assert invoice.errors.invalid?(:bill_to_address)
      assert invoice.errors.invalid?(:invoice_items)
      assert invoice.errors.invalid?(:due_dates)
    end
end
