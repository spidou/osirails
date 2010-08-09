require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseOrderTest < ActiveSupport::TestCase
  
  should_have_many :purchase_order_supplies
  should_have_many :parcel_items
  
  should_belong_to :invoice_document, :quotation_document, :user, :supplier
  
  should_validate_presence_of :user_id
  should_validate_presence_of :supplier_id
  
  context 'A new "purchase order"' do
    setup do
      @purchase_order = PurchaseOrder.new
    end
    
    should 'return false to "was_draft?" method' do
      assert !@purchase_order.was_draft?
    end
    
    should 'return false to "draft?" method' do
      assert !@purchase_order.draft?
    end
    
    should 'return false to "was_confirmed?" method' do
      assert !@purchase_order.was_confirmed?
    end
    
    should 'return false to "confirmed?" method' do
      assert !@purchase_order.confirmed?
    end
    
    should 'return false to "was_processing_by_supplier?" method' do
      assert !@purchase_order.was_processing_by_supplier?
    end
    
    should 'return false to "processing_by_supplier?" method' do
      assert !@purchase_order.processing_by_supplier?
    end
    
    should 'return false to "was_completed?" method' do
      assert !@purchase_order.was_completed?
    end
    
    should 'return false to "completed?" method' do
      assert !@purchase_order.completed?
    end
    
    should 'return false to "was_cancelled?" method' do
      assert !@purchase_order.was_cancelled?
    end
    
    should 'return false to "cancelled?" method' do
      assert !@purchase_order.cancelled?
    end
    
    should 'have status set to nil' do
      assert_nil @purchase_order.status
    end
    
    should 'have status set to "draft" on validation on create' do
      @purchase_order.valid?
      assert_equal PurchaseOrder::STATUS_DRAFT, @purchase_order.status
    end
    
    should 'have invalid "purchase_order_supplies"' do
      @purchase_order.valid?
      assert_match /Veuillez sélectionner au moins une fourniture/, @purchase_order.errors.on(:purchase_order_supplies)
    end
    
    should 'NOT be able to be confirmed' do
      assert !@purchase_order.can_be_confirmed?
    end
    
    should 'NOT be able to be processed by supplier' do
      assert !@purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be able to be edited' do
      assert !@purchase_order.can_be_edited?
    end
    
    should 'NOT be able to be deleted' do
      assert !@purchase_order.can_be_deleted?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@purchase_order.can_be_cancelled?
    end
    
    should 'be NOT able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'NOT be confirmed successfully' do
        assert !@purchase_order.confirm
    end
    
    should 'NOT be processed by supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.complete
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    context 'with "purchase_order_supplies"' do
      setup do
        build_purchase_order_supply( @purchase_order, { :supplier_reference => "C.01012010",
                                                          :supplier_designation => "First Purchase Order Supply" })
      end
      
      should 'have valid "purchase_order_supplies"' do
        @purchase_order.valid?
        assert_nil @purchase_order.errors.on(:purchase_order_supplies)
      end
      
      context ', with user_id and supplier_id' do
        setup do
          @purchase_order.user_id = users("admin_user").id
          @purchase_order.supplier_id = thirds("first_supplier").id
        end
        
        should 'be saved' do
          assert @purchase_order.save!
        end
      end
    end # end context 'with "purchase_order_supplies"'#
    
    context 'generated from a "purchase_request" with 2 "purchase_request_supplies"' do
      setup do
        @purchase_request = create_purchase_request
        @purchase_order.supplier_id = thirds("first_supplier")
        flunk '"Purchase_order_supplies" are not empty' unless @purchase_order.purchase_order_supplies.empty?
        @purchase_order.build_with_purchase_request_supplies(@purchase_request.purchase_request_supplies)
      end
      
      should 'have 2 "purchase_order_supplies" generated from "purchase_request_supplies"' do
        assert_equal 2, @purchase_order.purchase_order_supplies.size
      end
    end
    
  end # end context 'A new "purchase_order"'#
  
  context 'A draft "purchase_order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_COMPLETED, PurchaseOrder::STATUS_CANCELLED
    should_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_CONFIRMED
    
    should 'return true to "was_draft?" method' do
      assert @purchase_order.was_draft?
    end
    
    should 'return true to "draft?" method' do
      assert @purchase_order.draft?
    end
    
    should 'return false to "was_confirmed?" method' do
      assert !@purchase_order.was_confirmed?
    end
    
    should 'return false to "confirmed?" method' do
      assert !@purchase_order.confirmed?
    end
    
    should 'return false to "was_processing_by_supplier?" method' do
      assert !@purchase_order.was_processing_by_supplier?
    end
    
    should 'return false to "processing_by_supplier?" method' do
      assert !@purchase_order.processing_by_supplier?
    end
    
    should 'return false to "was_completed?" method' do
      assert !@purchase_order.was_completed?
    end
    
    should 'return false to "completed?" method' do
      assert !@purchase_order.completed?
    end
    
    should 'return false to "was_cancelled?" method' do
      assert !@purchase_order.was_cancelled?
    end
    
    should 'return false to "cancelled?" method' do
      assert !@purchase_order.cancelled?
    end
    
    should 'have status initialized to "draft"' do
      assert_equal PurchaseOrder::STATUS_DRAFT, @purchase_order.status_was
    end
    
    should 'be able to be confirmed' do
      assert @purchase_order.can_be_confirmed?
    end
    
    should 'NOT be able to be processing by supplier' do
      assert !@purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'be able to be edited' do
      assert @purchase_order.can_be_edited?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@purchase_order.can_be_cancelled?
    end
    
    should 'be NOT able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'be able to be deleted' do
      assert @purchase_order.can_be_deleted?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'NOT be processing by supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.complete
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'be deleted successfully' do
      assert @purchase_order.destroy
    end
    
    should 'assert that there is 2 purchase_order_supply not cancelled' do
      assert_equal 2, @purchase_order.not_cancelled_purchase_order_supplies.size
    end
    
    context 'with only one "purchase_order_supply" set to should_destroy' do
      setup do
        @purchase_order.purchase_order_supplies.first.should_destroy = 1
        @purchase_order.valid?
      end
      
      should 'be valid and be able to destroy it' do
        assert_nil @purchase_order.errors.on(:purchase_order_supplies)
      end
    end # end context 'with one "purchase_order_supply" set to should_destroy' #
    
    context 'with all "purchase_order_supplies" set to should_destroy' do
      setup do
        @purchase_order.purchase_order_supplies.each{ |s| s.should_destroy = 1 }
        @purchase_order.valid?
      end
      
      should 'NOT be valid and able to destroy all' do
        assert_not_nil @purchase_order.errors.on(:purchase_order_supplies)
      end
    end # end context 'with all "purchase order supplies" set to should_destroy'
    
    context 'with associated "request_order_supplies" selected and built' do
      setup do
        @purchase_request = create_purchase_request
        fill_associated_pos_with_prs_ids_which_have_the_same_supply_id(@purchase_order, @purchase_request)
      end
      
      should 'have 2 "purchase_request_supplies" associated' do
        counter = @purchase_order.purchase_order_supplies.select{ |s| s.purchase_request_supplies.any? }.size
        assert_equal 2, counter
      end
    
      context ', then deselected' do
        setup do
          fill_associated_pos_with_prs_ids_which_have_the_same_supply_id_to_deselect(@purchase_order, @purchase_request)
          @purchase_order.save!
        end
        
        should 'NOT have "purchase_request" associated' do
          counter = @purchase_order.purchase_order_supplies.select{ |s| s.purchase_request_supplies.any? }.size
          assert_equal 0, counter
        end
      end # end context 'then deselected' #
    end # end context 'with associated "request_order_supplies" selected and built' #
    
    context 'with a "quotation_document" set directly by quotation_document_attributes' do
      setup do
        @purchase_order.quotation_document_attributes = [{:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif"))}]
      end
      
      should 'have a "quotation_document"' do
        assert @purchase_order.quotation_document
      end
    end
    
    context 'while confirmation' do
      setup do
        flunk 'reference should be nil' if @purchase_order.reference
        flunk 'confirmed_on should be nil' if @purchase_order.confirmed_on
        @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
        @purchase_order.confirmed_on = Date.today
        @purchase_order.status = PurchaseOrder::STATUS_CONFIRMED
      end
      
      subject{ @purchase_order }
      
      should_validate_presence_of :reference
      should_validate_presence_of :quotation_document
      
      should 'be able to be confirmed' do
        assert @purchase_order.can_be_confirmed?
      end
      
      should 'be confirmed successfully' do
        assert @purchase_order.confirm
      end
    end # end context 'while confirmation' #
    
    context 'with a "purchase_order_supply" ordering a non-existent "supplier_supplies"' do
      setup do
        flunk '"Supplier_supply" should NOT exist yet' if SupplierSupply.find_by_supplier_id_and_supply_id(thirds("first_supplier").id, supplies("second_consumable").id)
        build_purchase_order_supply( @purchase_order, { :supply_id => supplies("second_consumable").id,
                                                        :quantity => 1324,
                                                        :taxes => 9,
                                                        :supplier_reference => "M.05012010",
                                                        :supplier_designation => "An Other Order Supply" })
        @purchase_order.save!
      end
      
      should 'have created the "supplier_supply"' do
        assert SupplierSupply.find_by_supplier_id_and_supply_id(thirds("first_supplier").id, supplies("second_consumable").id)
      end
    end # end context 'with non-existent "supplier_supplies"' #
  end  # end context 'A draft "purchase_order"' #
  
  context 'A confirmed "purchase order" without associated "purchase_request"' do
    setup do
      @purchase_order = create_a_confirmed_purchase_order
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_COMPLETED
    should_allow_values_for :status, PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_CANCELLED
    
    should 'return false to "was_draft?" method' do
      assert !@purchase_order.was_draft?
    end
    
    should 'return false to "draft?" method' do
      assert !@purchase_order.draft?
    end
    
    should 'return true to "was_confirmed?" method' do
      assert @purchase_order.was_confirmed?
    end
    
    should 'return true to "confirmed?" method' do
      assert @purchase_order.confirmed?
    end
    
    should 'return false to "was_processing_by_supplier?" method' do
      assert !@purchase_order.was_processing_by_supplier?
    end
    
    should 'return false to "processing_by_supplier?" method' do
      assert !@purchase_order.processing_by_supplier?
    end
    
    should 'return false to "was_completed?" method' do
      assert !@purchase_order.was_completed?
    end
    
    should 'return false to "completed?" method' do
      assert !@purchase_order.completed?
    end
    
    should 'return false to "was_cancelled?" method' do
      assert !@purchase_order.was_cancelled?
    end
    
    should 'return false to "cancelled?" method' do
      assert !@purchase_order.cancelled?
    end
    
    should 'have status set to "confirmed"' do
      assert_equal PurchaseOrder::STATUS_CONFIRMED, @purchase_order.status_was
    end
    
    should 'NOT be able to be confirmed' do
      assert !@purchase_order.can_be_confirmed?
    end
    
    should 'be able to be processing by supplier' do
      assert @purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be able to be deleted' do
      assert !@purchase_order.can_be_deleted?
    end
  
    should 'be able to be cancelled' do
      assert @purchase_order.can_be_cancelled?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'be processing_by_supplier successfully' do
      assert @purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.complete
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'have a total price equal to 28200' do 
      #for purchase_order_supply in @purchase_order.purchase_order_supplies
      # => purchase_order_supply price = quantity * (fob_unit_price * (1 + (taxes/100)))
      #             18000              =  1000    * (    12         * (1 + ( 50  /100)))
      #                                                          +
      #             10200              =  2000    * (     3         * (1 + ( 70  /100)))
      #                                                          =
      #                                                        28200
      #end
      
      assert_equal 28200, @purchase_order.total_price
    end
    
    should 'NOT have all purchase_order_supplies be treated' do
      assert !@purchase_order.are_all_purchase_order_supplies_treated?
    end
    
    should 'return 0 associated "purchase_requests"' do
      assert @purchase_order.associated_purchase_requests.empty?
    end
    
    context 'with a "parcel" NOT containing all "purchase_order_supplies"' do
      setup do
        @purchase_order.parcels.build(  :status => Parcel::STATUS_PROCESSING_BY_SUPPLIER,
                                        :conveyance => "ship",
                                        :previsional_delivery_date => (Date.today + 10),
                                        :processing_by_supplier_since => (Date.today - 10))
        @purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                          :purchase_order_supply_id => @purchase_order.purchase_order_supplies.first.id,
                                                          :quantity => (@purchase_order.purchase_order_supplies.first.quantity - 1) )
        @purchase_order.save!
        flunk 'should remain "purchase_order_supplies" to make "parcels"' unless @purchase_order.is_remaining_quantity_for_parcel?
        @purchase_order.reload
      end
      
      should 'have status automatically switched to "processing_by_supplier"' do
        assert_equal PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, @purchase_order.status_was
      end
      
      should 'remain "purchase_order_supplies" to add "parcels"' do
        assert @purchase_order.is_remaining_quantity_for_parcel?
      end
      
      should 'be able to add "parcels"' do
        assert @purchase_order.can_add_parcel?
      end
    end # end context 'with a "parcel" NOT containing all "purchase_order_supplies"' #
    
    context 'with a "parcel" containing all "purchase_order_supplies"' do
      setup do
        @purchase_order.parcels.build(  :status => Parcel::STATUS_PROCESSING_BY_SUPPLIER,
                                        :conveyance => "ship",
                                        :previsional_delivery_date => (Date.today + 10),
                                        :processing_by_supplier_since => (Date.today - 10))
        @purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                          :purchase_order_supply_id => @purchase_order.purchase_order_supplies.first.id,
                                                          :quantity => (@purchase_order.purchase_order_supplies.first.quantity) )
        @purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                          :purchase_order_supply_id => @purchase_order.purchase_order_supplies[1].id,
                                                          :quantity => (@purchase_order.purchase_order_supplies[1].quantity) )
        @purchase_order.save!
        @purchase_order.reload # necessary because @purchase_order.purchase_order_supplies are not associated with parcel_items otherwise
        flunk 'should NOT remain "purchase_order_supplies" to make "parcels"' unless !@purchase_order.is_remaining_quantity_for_parcel?
      end
      
      should 'have status automatically switched to "processing_by_supplier"' do
        assert_equal PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, @purchase_order.status_was
      end
      
      should 'NOT remain "purchase_order_supplies" to add "parcels"' do
        assert !@purchase_order.is_remaining_quantity_for_parcel?
      end
      
      should 'NOT be able to add "parcels"' do
        assert !@purchase_order.can_add_parcel?
      end
    end # end context 'with a "parcel" containing all "purchase_order_supplies"' #
    
    context ', while cancellation' do
      setup do
        flunk 'cancelled_at should be nil' if @purchase_order.cancelled_at
        flunk 'cancelled_comment should be nil' if @purchase_order.cancelled_comment
        flunk 'cancelled_by_id should be nil' if @purchase_order.cancelled_by_id
        @purchase_order.cancelled_comment = "Cancelled for tests"
        @purchase_order.cancelled_by_id = users("admin_user").id
        @purchase_order.status = PurchaseOrder::STATUS_CANCELLED
      end
      
      subject { @purchase_order }
      
      should_validate_presence_of :cancelled_comment
      should_validate_presence_of :cancelled_by_id
      
      should 'be able to be cancelled' do
        @purchase_order.can_be_cancelled?
      end
      
      should 'be cancelled' do
        @purchase_order.cancel
      end
    end # end context 'while cancellation' #
  end # end context 'A confirmed "purchase_order"' #
  
  context 'A secondary "purchase_order" associated with a "purchase_request_supply" in an already confirmed "purchase_order"' do
    setup do
      @first_purchase_order = create_a_confirmed_purchase_order
      @secondary_purchase_order = create_purchase_order
      @purchase_request = create_purchase_request
      fill_associated_pos_with_prs_ids_which_have_the_same_supply_id(@first_purchase_order, @purchase_request)
      fill_associated_pos_with_prs_ids_which_have_the_same_supply_id(@secondary_purchase_order, @purchase_request)
      @first_purchase_order.reload
      @secondary_purchase_order.reload
      flunk 'the first "purchase_order" do not contain one "purchase_request"' unless @first_purchase_order.associated_purchase_requests.size == 1
      flunk 'the secondary "purchase_order" do not contain one "purchase_request"' unless @secondary_purchase_order.associated_purchase_requests.size == 1
      flunk 'the two "purchase_order" are not associated with the same "purchase_request"' unless @first_purchase_order.associated_purchase_requests.first == @secondary_purchase_order.associated_purchase_requests.first
    end
    
    should 'NOT be able to confirmed' do
      assert !@secondary_purchase_order.can_be_confirmed?
    end
  end #end context 'A secondary "purchase_order" containing an association with an already confirmed "purchase_order"' #
  
  context 'A processing "purchase_order" without all "purchase_order_supplies" treated' do
    setup do
      @purchase_order = create_a_processing_purchase_order
      @purchase_order.reload
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_CONFIRMED
    should_allow_values_for :status, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER,  PurchaseOrder::STATUS_COMPLETED, PurchaseOrder::STATUS_CANCELLED
    
    should 'return false to "was_draft?" method' do
      assert !@purchase_order.was_draft?
    end
    
    should 'return false to "draft?" method' do
      assert !@purchase_order.draft?
    end
    
    should 'return false to "was_confirmed?" method' do
      assert !@purchase_order.was_confirmed?
    end
    
    should 'return false to "confirmed?" method' do
      assert !@purchase_order.confirmed?
    end
    
    should 'return true to "was_processing_by_supplier?" method' do
      assert @purchase_order.was_processing_by_supplier?
    end
    
    should 'return true to "processing_by_supplier?" method' do
      assert @purchase_order.processing_by_supplier?
    end
    
    should 'return false to "was_completed?" method' do
      assert !@purchase_order.was_completed?
    end
    
    should 'return false to "completed?" method' do
      assert !@purchase_order.completed?
    end
    
    should 'return false to "was_cancelled?" method' do
      assert !@purchase_order.was_cancelled?
    end
    
    should 'return false to "cancelled?" method' do
      assert !@purchase_order.cancelled?
    end
    
    should 'have status set to "processing_by_supplier"' do
      assert_equal PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, @purchase_order.status
    end
    
    should 'NOT be able to be confirmed' do
      assert !@purchase_order.can_be_confirmed?
    end
    
    should 'NOT be able to be processing by supplier' do
      assert !@purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be able to be edited' do
      assert !@purchase_order.can_be_edited?
    end
          
    should 'NOT be able to be deleted' do
      assert !@purchase_order.can_be_deleted?
    end
    
    should 'be able to be cancelled' do
      assert @purchase_order.can_be_cancelled?
    end
    
    should 'be able to add "parcels"' do
      assert @purchase_order.can_add_parcel?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'NOT be processing_by_supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    context 'with a "invoice_document" set directly by quotation_document_attributes' do
      setup do
        @purchase_order.invoice_document_attributes = [{:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "invoice_document.gif"))}]
      end
      
      should 'have a "invoice_document"' do
        assert @purchase_order.invoice_document
      end
    end
  end # end context 'A processing "purchase order" without all "purchase_order_supplies" treated' #
  
  context 'A processing "purchase order" with all "purchase order supplies" treated, while completion' do
    setup do
      @purchase_order = create_a_confirmed_purchase_order
      @purchase_order = prepare_purchase_order_to_be_completed(@purchase_order)
    end
    
    should 'be able to be completed' do
      assert @purchase_order.can_be_completed?
    end
    
    should 'NOT be able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'be completed successfully' do
      assert @purchase_order.can_be_completed?
    end
    
    should 'all purchase_order_supplies be treated' do
      assert @purchase_order.are_all_purchase_order_supplies_treated?
    end
  end # end context 'A processing "purchase order" with all "purchase order supplies" treated, while completion' #
  
  context 'A completed "purchase_order"' do
    setup do
      @purchase_order = create_a_confirmed_purchase_order
      @purchase_order = prepare_purchase_order_to_be_completed(@purchase_order)
      @purchase_order.complete
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_CANCELLED
    should_allow_values_for :status, PurchaseOrder::STATUS_COMPLETED
    
    should 'return false to "was_draft?" method' do
      assert !@purchase_order.was_draft?
    end
    
    should 'return false to "draft?" method' do
      assert !@purchase_order.draft?
    end
    
    should 'return false to "was_confirmed?" method' do
      assert !@purchase_order.was_confirmed?
    end
    
    should 'return false to "confirmed?" method' do
      assert !@purchase_order.confirmed?
    end
    
    should 'return false to "was_processing_by_supplier?" method' do
      assert !@purchase_order.was_processing_by_supplier?
    end
    
    should 'return false to "processing_by_supplier?" method' do
      assert !@purchase_order.processing_by_supplier?
    end
    
    should 'return true to "was_completed?" method' do
      assert @purchase_order.was_completed?
    end
    
    should 'return true to "completed?" method' do
      assert @purchase_order.completed?
    end
    
    should 'return false to "was_cancelled?" method' do
      assert !@purchase_order.was_cancelled?
    end
    
    should 'return false to "cancelled?" method' do
      assert !@purchase_order.cancelled?
    end
    
    should 'have status set to "completed"' do
      assert_equal PurchaseOrder::STATUS_COMPLETED, @purchase_order.status
    end
    
    should 'NOT be able to be confirmed' do
      assert !@purchase_order.can_be_confirmed?
    end
    
    should 'NOT be able to be processing by supplier' do
      assert !@purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be able to be edited' do
      assert !@purchase_order.can_be_edited?
    end
          
    should 'NOT be able to be deleted' do
      assert !@purchase_order.can_be_deleted?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@purchase_order.can_be_cancelled?
    end
    
    should 'NOT be able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'NOT be processing_by_supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
  end # end context 'A completed "purchase_order"' #
  
  context 'A "purchase_order" with all "purchase_order_supplies" cancelled' do
    setup do
      @purchase_order = create_a_confirmed_purchase_order
      @purchase_order.purchase_order_supplies.reload # reload is necessary because the join between purchase_order_supply and purchase_order (purchase_order_supply.purchase_order) is not update otherwise. Then the purchase_order seems not conformed yet and don't work so
      for purchase_order_supply in @purchase_order.not_cancelled_purchase_order_supplies
        purchase_order_supply.cancelled_comment = "cancelled for tests"
        purchase_order_supply.cancelled_by_id = users("admin_user").id
        flunk '"Purchase_order_supply" cancellation failed' unless purchase_order_supply.cancel
      end
    end
    
    should 'have status set to "cancelled"' do
      assert @purchase_order.was_cancelled?
    end
  end # end context 'A "purchase_order" with all "purchase_order_supplies" cancelled' #
  
  context 'A cancelled "purchase_order"' do
    setup do
      @purchase_order = create_a_confirmed_purchase_order
      @purchase_order.cancelled_by_id = users("admin_user").id
      @purchase_order.cancelled_comment = "Test comment"
      @purchase_order.cancel
    end
    
    subject { @purchase_order }
    
    should_validate_presence_of :cancelled_comment, :cancelled_by_id
    
    should 'return false to "was_draft?" method' do
      assert !@purchase_order.was_draft?
    end
    
    should 'return false to "draft?" method' do
      assert !@purchase_order.draft?
    end
    
    should 'return false to "was_confirmed?" method' do
      assert !@purchase_order.was_confirmed?
    end
    
    should 'return false to "confirmed?" method' do
      assert !@purchase_order.confirmed?
    end
    
    should 'return false to "was_processing_by_supplier?" method' do
      assert !@purchase_order.was_processing_by_supplier?
    end
    
    should 'return false to "processing_by_supplier?" method' do
      assert !@purchase_order.processing_by_supplier?
    end
    
    should 'return false to "was_completed?" method' do
      assert !@purchase_order.was_completed?
    end
    
    should 'return false to "completed?" method' do
      assert !@purchase_order.completed?
    end
    
    should 'return true to "was_cancelled?" method' do
      assert @purchase_order.was_cancelled?
    end
    
    should 'return true to "cancelled?" method' do
      assert @purchase_order.cancelled?
    end
    
    should 'have status set to "cancelled"' do
      assert_equal PurchaseOrder::STATUS_CANCELLED, @purchase_order.status
    end
    
    should 'NOT be able to be confirmed' do
      assert !@purchase_order.can_be_confirmed?
    end
    
    should 'NOT be able to be processing by supplier' do
      assert !@purchase_order.can_be_processed_by_supplier?
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be able to be edited' do
      assert !@purchase_order.can_be_edited?
    end
          
    should 'NOT be able to be deleted' do
      assert !@purchase_order.can_be_deleted?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@purchase_order.can_be_cancelled?
    end
    
    should 'NOT be able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'NOT be processing_by_supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be completed successfully' do
      assert !@purchase_order.can_be_completed?
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'have a total price equal to 0000 with cancelled purchase_order_supplies counted' do
      assert_equal 31800, @purchase_order.total_price
    end
  end # end context 'A cancelled "purchase_order"' #
end
