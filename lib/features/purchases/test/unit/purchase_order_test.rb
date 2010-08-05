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
    
#    should 'NOT be edited successfully' do
#      assert !@purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    context 'with "purchase_order_supplies"' do
      setup do
        build_purchase_order_supplies( @purchase_order, { :supplier_reference => "C.01012010",
                                                          :supplier_designation => "First Purchase Order Supply" })
      end
      
      should 'have valid "purchase_order_supplies"' do
        @purchase_order.valid?
        assert_no_match /Veuillez sélectionner au moins une fourniture/, @purchase_order.errors.on(:purchase_order_supplies)
      end
      
      context 'with user_id and supplier_id' do
        setup do
          @purchase_order.user_id = 1
          @purchase_order.supplier_id = 1
        end
        
        should 'be saved' do
          assert @purchase_order.save!
        end
      end
      
    end # end context 'with "purchase_order_supplies"'#
        
  end # end context 'A new "purchase_order"'#
  
  context 'A draft "purchase order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.purchase_order_supplies.first.should_destroy = 1
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
    
#    should 'be edited' do
#      assert @purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'be deleted successfully' do
      assert @purchase_order.destroy
    end
    
    should 'assert that there is 2 purchase_order_supply not cancelled' do
      assert_equal 2, @purchase_order.not_cancelled_purchase_order_supplies.size
    end
    
    should 'let destroy whether NOT all "purchase_order_supplies" are set to should destroy' do
      @purchase_order.validates_length_of_purchase_order_supplies
      assert_no_match /Veuillez sélectionner au moins une fourniture/, @purchase_order.errors.on(:purchase_order_supplies)
    end
    
    context 'with all "purchase order supplies" set to should_destroy' do
      setup do
        for purchase_order_supply in @purchase_order.purchase_order_supplies
          purchase_order_supply.should_destroy = 1
        end
      end
      
      should 'NOT let destroy all "purchase_order_supplies" set to should destroy' do
        @purchase_order.validates_length_of_purchase_order_supplies
        assert_match /Veuillez sélectionner au moins une fourniture/, @purchase_order.errors.on(:purchase_order_supplies)
      end
    end # end context 'with all "purchase order supplies" set to should_destroy'
    
    context 'built associated "purchase_request_supplies"' do
      setup do
        create_associated_purchase_request_with_purchase_order(@purchase_order)
        for purchase_order_supply in @purchase_order.purchase_order_supplies
          for purchase_request_supply in purchase_order_supply.purchase_request_supplies
            purchase_order_supply.purchase_request_supplies_ids += purchase_request_supply.id.to_s + "\;"
          end
        end
        @purchase_order.build_associated_request_order_supplies
      end
      
      should 'have 2 associated "purchase_request_supplies" associated' do
        flunk 'test'
      end
    end
    
    context 'with a "purchase_request" associated' do
      setup do
        create_associated_purchase_request_with_purchase_order(@purchase_order)
      end
      
      should 'have "purchase_request" associated' do
        counter = 0
        for purchase_order_supply in @purchase_order.purchase_order_supplies
          counter += 1 if purchase_order_supply.purchase_request_supplies.any?
        end
        assert_equal 2, counter
      end
      
#      context 'and "purchase_request" deselected' do
#        setup do
#          for purchase_order_supply in @purchase_order.purchase_order_supplies
#            purchase_order_supply.purchase_request_supplies_deselected_ids = ""
#            for purchase_request_supply in purchase_order_supply.purchase_request_supplies
#              purchase_order_supply.purchase_request_supplies_deselected_ids += (purchase_request_supply.id.to_s + "\;")
#            end
#          end
#          @purchase_order.destroy_request_order_supplies_deselected
#        end
#        
#        should 'NOT have "purchase_request" associated' do
#          counter = 0
#          for purchase_order_supply in @purchase_order.purchase_order_supplies
#            counter += 1 if purchase_order_supply.purchase_request_supplies.any?
#          end
#          assert_equal 0, counter
#        end
#      end
    end
    
    context 'while confirmation' do
      setup do
        @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      end
      
      should 'be able to be confirmed' do
        assert @purchase_order.can_be_confirmed?
      end
      
      should 'be confirmed' do
        assert @purchase_order.confirm
      end
    end
  end
  
  context 'A confirmed "purchase order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      @purchase_order.confirm
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_COMPLETED
    should_allow_values_for :status, PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_CANCELLED
    should_validate_presence_of :quotation_document

    
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
    
#    should 'NOT be edited successfully' do
#      assert !@purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT all purchase_order_supplies be treated' do
      assert !@purchase_order.are_all_purchase_order_supplies_treated?
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
        @purchase_order.reload
      end
      
      should 'have status automatically switched to "processing_by_supplier"' do
        @purchase_order.valid?
        assert_equal PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, @purchase_order.status_was
      end
      
      should 'remain "purchase_order_supplies" to add "parcels"' do
        assert @purchase_order.is_remaining_quantity_for_parcel?
      end
      
      should 'be able to add "parcels"' do
        assert @purchase_order.can_add_parcel?
      end
    end # end context 'with a "parcel" NOT containing all "purchase_order_supplies"'
    
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
        @purchase_order.reload
      end
      
      should 'have status automatically switched to "processing_by_supplier"' do
        @purchase_order.valid?
        assert_equal PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, @purchase_order.status_was
      end
      
      should 'NOT remain "purchase_order_supplies" to add "parcels"' do
        assert !@purchase_order.is_remaining_quantity_for_parcel?
      end
      
      should 'NOT be able to add "parcels"' do
        assert !@purchase_order.can_add_parcel?
      end
    end # end context 'with a "parcel" containing all "purchase_order_supplies"'
  end
  
  context 'A processing "purchase order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      @purchase_order.confirm
      @purchase_order.parcels.build(  :status => Parcel::STATUS_PROCESSING_BY_SUPPLIER,
                                      :conveyance => "ship",
                                      :previsional_delivery_date => (Date.today + 10),
                                      :processing_by_supplier_since => Date.today)
      @purchase_order.parcels.first.parcel_items.build( :selected => "1",
                                                        :purchase_order_supply_id => @purchase_order.purchase_order_supplies.first.id,
                                                        :quantity => (@purchase_order.purchase_order_supplies.first.quantity) )
      @purchase_order.save!
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
    
#    should 'be edited successfully' do
#      assert @purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
  end # end context 'A processing "purchase order"' #
  
  context 'A processing "purchase order" with all "purchase order supplies" treated' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      @purchase_order.confirm
      @purchase_order = prepare_purchase_order_to_be_completed(@purchase_order)
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
    
    should 'be able to be completed' do
      assert @purchase_order.can_be_completed?
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
    
    should 'NOT be able to add "parcels"' do
      assert !@purchase_order.can_add_parcel?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@purchase_order.confirm
    end
    
    should 'NOT be processing_by_supplier successfully' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'be completed successfully' do
      assert @purchase_order.can_be_completed?
    end
    
#    should 'NOT be edited successfully' do
#      assert !@purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'all purchase_order_supplies be treated' do
      assert @purchase_order.are_all_purchase_order_supplies_treated?
    end
    
  end # end context 'A processing "purchase order" with all "purchase order supplies" treated' #
  
  context 'A completed "purchase_order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      @purchase_order.confirm
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
    
#    should 'NOT be edited successfully' do
#      assert !@purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
    
  end # end context 'A completed "purchase_order"' #
  
  context 'A cancelled "purchase_order"' do
    setup do
      @purchase_order = create_a_draft_purchase_order
      @purchase_order.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      @purchase_order.confirm
      @purchase_order.cancelled_by_id = users(:admin_user).id
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
    
#    should 'NOT be edited successfully' do
#      assert !@purchase_order.update_attributes(@purchase_order.attributes)
#    end
    
    should 'NOT be deleted successfully' do
      assert !@purchase_order.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@purchase_order.cancel
    end
  end # end context 'A cancelled "purchase_order"' #
end
