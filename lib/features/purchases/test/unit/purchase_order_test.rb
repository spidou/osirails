require 'test/test_helper'
require File.dirname(__FILE__) + '/../purchases_test'

class PurchaseOrderTest < ActiveSupport::TestCase
  
  should_have_many :purchase_order_supplies
  should_have_many :parcel_items
  
  should_belong_to :invoice_document, :quotation_document, :canceller, :user, :supplier
  
  should_validate_presence_of :user_id
  should_validate_presence_of :supplier_id
  
  context 'A new "purchase order"' do
      
    setup do
      @purchase_order = PurchaseOrder.new
      @purchase_order.supplier_id = 1
      @purchase_order.user_id = 1
    end
    
    subject { @purchase_order }
    
    should_not_allow_values_for :status, PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_COMPLETED, PurchaseOrder::STATUS_CANCELLED
    should_allow_values_for :status, PurchaseOrder::STATUS_DRAFT
    
    should 'NOT be valid' do
      @purchase_order.valid?
      assert_match /Veuillez selectionner au moins une matiere premiere ou un consommable/, @purchase_order.errors.on(:purchase_order_supplies)
    end
    
    should 'NOT be able to be confirmed' do
        assert !@purchase_order.confirm
    end
    
    should 'NOT be able to be processing by supplier' do
      assert !@purchase_order.process_by_supplier
    end
    
    should 'NOT be able to be completed' do
      assert !@purchase_order.complete
    end
    
    should 'NOT be able to be cancelled' do
      assert !@purchase_order.cancel
    end
    
    should 'be able to be deleted' do
      assert @purchase_order.destroy
    end
    
    context 'with "purchase_order_supplies"' do
      setup do
        @purchase_order.status = PurchaseOrder::STATUS_DRAFT
        commodity = supplies(:first_commodity)
        consumable = supplies(:first_consumable)
        build_purchase_order_supplies(@purchase_order, { :supply_id => commodity.id,
                                                        :quantity => 1000,
                                                        :taxes => 50,
                                                        :fob_unit_price => 12,
                                                        :supplier_reference => "C.01012010",
                                                        :supplier_designation => "First Purchase Order Supply" })
        build_purchase_order_supplies(@purchase_order, { :supply_id => consumable.id,
                                                        :quantity => 2000,
                                                        :taxes => 70,
                                                        :fob_unit_price => 3,
                                                        :supplier_reference => "M.01012010",
                                                        :supplier_designation => "Second Purchase Order Supply" })
      end
      
      subject { @purchase_order }
      
      should 'be valid' do
        @purchase_order.valid?
        assert_no_match /Veuillez selectionner au moins une matiere premiere ou un consommable/, @purchase_order.errors.on(:purchase_order_supplies)
      end
        
      should 'be saved' do
        assert @purchase_order.save!
      end
      
      should 'NOT be able to be confirmed' do
        assert !@purchase_order.confirm
      end
      
      should 'NOT be able to be processing by supplier' do
        assert !@purchase_order.process_by_supplier
      end
      
      should 'NOT be able to be completed' do
        assert !@purchase_order.complete
      end
      
      should 'NOT be able to be cancelled' do
        assert !@purchase_order.cancel
      end
      
      should 'be able to be deleted' do
        assert @purchase_order.destroy
      end
      
      context '. Then becomes a draft "purchase order"' do
        setup do
          @purchase_order.status = PurchaseOrder::STATUS_DRAFT
          @purchase_order.created_at = Time.now
          @purchase_order.save!
        end
        
        subject { @purchase_order }
        
        should_not_allow_values_for :status, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_COMPLETED, PurchaseOrder::STATUS_CANCELLED
        should_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_CONFIRMED
        
        should 'not have possibility to destroy the last "purchase order supply"' do
          #TODO
        end
        
        should 'be in status "DRAFT"' do
          assert @purchase_order.was_draft?
        end
        
        should 'NOT be able to be confirmed' do
          assert !@purchase_order.confirm
        end
        
        should 'NOT be able to be processing by supplier' do
          assert !@purchase_order.process_by_supplier
        end
        
        should 'NOT be able to be completed' do
          assert !@purchase_order.complete
        end
        
        should 'NOT be able to be cancelled' do
          assert !@purchase_order.cancel
        end
        
        should 'be able to be deleted' do
          assert @purchase_order.destroy
        end
        
        context 'without "purchase order supplies"' do
          setup do
            destroy_all_purchase_order_supplies(@purchase_order)
          end
          
          subject { @purchase_order }
          
          should 'NOT be valid' do
            @purchase_order.valid?
            assert_match /Veuillez selectionner au moins une matiere premiere ou un consommable/, @purchase_order.errors.on(:purchase_order_supplies)
          end
        end
        
        context 'with "quotation_document"' do
          setup do
            purchase_document_build(@purchase_order, :purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
          end
          
          subject { @purchase_order }
          
          should 'be able to be confirmed' do
            assert @purchase_order.confirm
          end
          
          should 'NOT be able to be processing by supplier' do
            assert !@purchase_order.process_by_supplier
          end
          
          should 'NOT be able to be completed' do
            assert !@purchase_order.complete
          end
          
          should 'NOT be able to be cancelled' do
            assert !@purchase_order.cancel
          end
          
          should 'be able to be deleted' do
            assert !@purchase_order.destroy
          end
          
          
          context '. Then becomes a confirmed "purchase order"' do
            setup do
              @purchase_order.confirm
            end
            
            subject { @purchase_order }
            
            should_not_allow_values_for :status, PurchaseOrder::STATUS_DRAFT, PurchaseOrder::STATUS_COMPLETED
            should_allow_values_for :status, PurchaseOrder::STATUS_CONFIRMED, PurchaseOrder::STATUS_PROCESSING_BY_SUPPLIER, PurchaseOrder::STATUS_CANCELLED
            
            should 'not have possibility to destroy the last "purchase order supply"' do
              #TODO
            end
            
            should 'be in status "CONFIRMED"' do
              assert @purchase_order.was_confirmed?
            end
            
            should 'NOT be able to be confirmed' do
              assert @purchase_order.confirm
            end
            
            should 'be able to be processing by supplier' do
              assert @purchase_order.process_by_supplier
            end
            
            should 'NOT be able to be completed' do
              assert !@purchase_order.complete
            end
            
            should 'be able to be cancelled' do
              assert @purchase_order.cancel
            end
            
          end
          
        end
        
      end
      
    end
    
  end
  
end
