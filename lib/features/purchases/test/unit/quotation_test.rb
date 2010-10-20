require File.dirname(__FILE__) + '/../purchases_test'

class QuotationTest < ActiveSupport::TestCase
  #TODO test has_permissions :as_business_object
  #TODO test validate_date
  
  should_have_many :quotation_supplies
  should_have_many :existing_quotation_supplies
  should_have_many :free_quotation_supplies
  
#  should_have_one :purchase_order
  
  should_belong_to :creator, :supplier, :quotation_document, :canceller, :quotation_request
  
  should_validate_presence_of :creator_id, :supplier_id, :quotation_document
  
  Quote::VALIDITY_DELAY_UNITS.values.each do |unit|
    should_allow_values_for   :validity_delay_unit, unit
  end
  
  context 'A new quotation' do
    setup do
      @quotation = Quotation.new
    end

    subject {@quotation}
    
    should_not_allow_values_for :status, Quotation::STATUS_CANCELLED
    should_allow_values_for :status, nil, Quotation::STATUS_SIGNED, Quotation::STATUS_SENT

    should 'NOT have the drafted status' do
      assert !@quotation.drafted?
    end
    
    should 'NOT have the signed status' do
      assert !@quotation.signed?
    end
    
    should 'NOT have the sent status' do
      assert !@quotation.sent?
    end
    
    should 'NOT have the cancelled status' do
      assert !@quotation.cancelled?
    end

    should 'NOT have the drafted status in the database' do
      assert !@quotation.was_drafted?
    end

    should 'NOT have the signed status in the database' do
      assert !@quotation.was_signed?
    end

    should 'NOT have the sent status in the database' do
      assert !@quotation.was_sent?
    end

    should 'NOT have the cancelled status in the database' do
      assert !@quotation.was_cancelled?
    end

    should 'NOT be able to be signed' do
      assert !@quotation.can_be_signed?
    end
    
    should 'NOT be able to be sent' do
      assert !@quotation.can_be_sent?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be cancelled' do
      @quotation.can_be_cancelled?
    end

    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'NOT be signed successfully' do
      assert !@quotation.sign
    end
    
    should 'NOT be sent successfully' do
      assert !@quotation.send_to_supplier
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
    
    should 'NOT be cancelled successfully with prerequisites' do
      @quotation.cancellation_comment = "Cancelled for tests"
      @quotation.canceller_id = users("admin_user").id
      assert !@quotation.cancel
    end
    
    should 'NOT have status signed or sent' do
      assert !@quotation.signed_or_sent?
    end
    
    should 'require at least one quotation_supply' do
      @quotation.valid?
      assert_match /Vous devez choisir au moins une fourniture./, @quotation.errors.on(:quotation_supplies)
    end

    should 'NOT be able to be associated with a purchase_order' do
      assert !@quotation.can_be_associated_with_a_purchase_order?
    end
    
    context 'with a quotation_supply' do
      setup do
        @quotation.supplier_id = thirds("first_supplier").id
        @quotation_supply = build_quotation_supply_for(@quotation)
        flunk '@quotation_supply is not valid' unless @quotation_supply.valid?
      end
      
      context 'and all attributes to be valid' do
        setup do
          make_quotation_valid(@quotation)
          flunk "@quotation is not valid" unless @quotation.valid?
        end
        
        context 'while signature' do
          setup do
            @quotation.status = Quotation::STATUS_SIGNED
          end
          
          subject {@quotation}

          should_validate_presence_of :signed_on

          context 'with signature date defined' do
            setup do
              @quotation.signed_on = Date.today
              @quotation.valid?
            end

            should 'be signed successfully' do
              assert @quotation.save
            end
          end
        end

        context 'while sending' do
          setup do
            @quotation.status = Quotation::STATUS_SENT
          end
          
          subject {@quotation}

          should_validate_presence_of :signed_on, :sent_on

          context 'with dates' do
            setup do
              @quotation.signed_on = Date.today
              @quotation.sent_on = Date.today
            end
            
            should 'NOT return error when sending' do
              assert @quotation.save!
            end
          end
        end
      end
    end
  end
  
  context 'A new quotation built from a quotation_request' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation = @quotation_request.build_prefilled_quotation
      flunk 'Failed to buil de quotation' unless @quotation
    end
    
    should 'have a supplier_id' do
      assert @quotation.supplier_id
    end

    should 'have an associated quotation_request' do
      assert @quotation.quotation_request
    end

    should 'have the same supplies that quotation_request' do
      assert_equal @quotation.quotation_request.supplier_id, @quotation.supplier_id    
    end
  end
  
  context 'A drafted quotation with a quotation_supply' do
    setup do
      @quotation = create_drafted_quotation
      @quotation.prizegiving = 10
    end
    
    subject {@quotation}
    
    should_allow_values_for :status, nil, Quotation::STATUS_CANCELLED, Quotation::STATUS_SIGNED, Quotation::STATUS_SENT
    
    should 'have the drafted status' do
      assert @quotation.drafted?
    end
    
    should 'NOT have the signed status' do
      assert !@quotation.signed?
    end
    
    should 'NOT have the sent status' do
      assert !@quotation.sent?
    end
    
    should 'NOT have the cancelled status' do
      assert !@quotation.cancelled?
    end
    
    should 'have the drafted status in the database' do
      assert @quotation.was_drafted?
    end
    
    should 'NOT have the signed status in the database' do
      assert !@quotation.was_signed?
    end
    
    should 'NOT have the sent status in the database' do
      assert !@quotation.was_sent?
    end
    
    should 'NOT have the cancelled status in the database' do
      assert !@quotation.was_cancelled?
    end
    
    should 'be able to be signed' do
      assert @quotation.can_be_signed?
    end
    
    should 'be able to be sent' do
      assert @quotation.can_be_sent?
    end
    
    should 'be able to be destroyed' do
      assert @quotation.can_be_destroyed?
    end
    
    should 'be able to be edited' do
      assert @quotation.can_be_edited?
    end
    
    should 'be able to be cancelled' do
      assert @quotation.can_be_cancelled?
    end
    
    should 'NOT be signed successfully' do
      assert !@quotation.sign
    end
    
    should 'NOT be sent successfully' do
      assert !@quotation.send_to_supplier
    end
    
    should 'be cancelled successfully with prerequisites' do
      @quotation.cancellation_comment = "Cancelled for tests"
      @quotation.canceller_id = users("admin_user").id
      assert @quotation.cancel
    end
    
    should 'be destroyed successfully' do
      assert @quotation.destroy
    end
    
    should 'NOT be able to be associated with a purchase_order' do
      assert !@quotation.can_be_associated_with_a_purchase_order?
    end
    
    should 'have a good total' do
      assert_equal 15000, @quotation.total
    end
    
    should 'have a good total_with_prizegiving' do
      assert_equal 15000, @quotation.total_with_prizegiving
    end
    
    should 'have a good net' do
      assert_equal 13500, @quotation.net
    end
    
    should 'have a good total_with_taxes' do
      assert_equal 18000, @quotation.total_with_taxes
    end
    
    should 'have a good summon_of_taxes' do
      assert_equal 3000, @quotation.summon_of_taxes
    end
    
    should 'have a good net_to_paid' do
      assert_equal 16500, @quotation.net_to_paid
    end
    
    context "then with a second quotation_supplies" do
      setup do
        @quotation.quotation_supplies.build(:supply_id => supplies("second_commodity").id,
                                            :quantity => 100,
                                            :taxes => 19.50,
                                            :unit_price => 10,
                                            :prizegiving => 2,
                                            :designation => supplies("second_commodity").designation,
                                            :supplier_designation => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("second_commodity").id).supplier_designation,
                                            :supplier_reference => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("second_commodity").id)).supplier_reference
      end
      
      should 'have a good total' do
        assert_equal 16000, @quotation.total
      end
      
      should 'have a good net' do
        assert_equal 14382.0, @quotation.net
      end
      
      should 'have a good total_with_taxes' do
        assert_equal @quotation.quotation_supplies.collect(&:total_with_taxes).sum, @quotation.total_with_taxes
      end
      
      should 'have a good summon_of_taxes' do
        assert_equal (@quotation.total_with_taxes - @quotation.total), @quotation.summon_of_taxes
      end
      
      should 'have a good net_to_paid' do
        assert_equal (@quotation.net.to_f + @quotation.carriage_costs.to_f + @quotation.summon_of_taxes.to_f), @quotation.net_to_paid.to_f
      end
    end
    
    context 'while signature' do
      setup do
        @quotation.status = Quotation::STATUS_SIGNED
      end
      
      subject {@quotation}
      
      should_validate_presence_of :signed_on
      
      context 'with signed_on' do
        setup do
          @quotation.signed_on = Date.today
        end
        
        should 'be save successfully' do
          assert @quotation.save
        end
      end
    end
    
  end
  
  context 'A signed quotation' do
    setup do
      @quotation = create_signed_quotation
    end

    subject{@quotation}

    should_not_allow_values_for :status, nil, Quotation::STATUS_SIGNED
    should_allow_values_for :status, Quotation::STATUS_SENT, Quotation::STATUS_CANCELLED
    
    should 'NOT have the drafted status in the database' do
      assert !@quotation.was_drafted?
    end
    
    should 'have the signed status in the database' do
      assert @quotation.was_signed?
    end
    
    should 'NOT have the sent status in the database' do
      assert !@quotation.was_sent?
    end
    
    should 'NOT have the cancelled status in the database' do
      assert !@quotation.was_cancelled?
    end

    should 'NOT have the drafted status' do
      assert !@quotation.drafted?
    end

    should 'have the signed status' do
      assert @quotation.signed?
    end

    should 'NOT have the sent status' do
      assert !@quotation.sent?
    end
    
    should 'have status signed or sent' do
      assert @quotation.signed_or_sent?
    end
    
    should 'NOT have the cancelled status' do
      assert !@quotation.cancelled?
    end
    
    should 'NOT be able to be signed' do
      assert !@quotation.can_be_signed?
    end
    
    should 'be able to be sent' do
      assert @quotation.can_be_sent?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'be able to be cancelled' do
      assert @quotation.can_be_cancelled?
    end
    
    should 'NOT be signed successfully' do
      assert !@quotation.sign
    end
    
    should 'NOT be sent successfully without signed_on defined' do
      assert !@quotation.send_to_supplier
    end
    
    should 'be cancelled successfully with prerequisites' do
      @quotation.cancellation_comment = "Cancelled for tests"
      @quotation.canceller_id = users("admin_user").id
      assert @quotation.cancel
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
    
    should 'be able to be associated with a purchase_order' do
      assert @quotation.can_be_associated_with_a_purchase_order?
    end
    
    context 'while cancellation' do
      setup do
        @quotation.status = Quotation::STATUS_CANCELLED
      end
      
      subject {@quotation}
      
      should_validate_presence_of :cancellation_comment, :canceller_id
      
      context 'and with required attributes' do
        setup do
          @quotation.cancellation_comment = "Cancelled for tests"
          @quotation.canceller_id = users("admin_user").id
        end
        
        should 'be saved successfully' do
          assert @quotation.save
        end
      end
    end
    
    context 'while sending' do
      setup do
        @quotation.status = Quotation::STATUS_SENT
      end
      
      subject {@quotation}
      
      should_validate_presence_of :sent_on
      
      context 'with sent_on' do
        setup do
          @quotation.sent_on = Date.today
        end
        
        should 'be save successfully' do
          assert @quotation.save
        end
      end
    end
    
    context 'associated with a purchase_order' do
      setup do
        @purchase_order = create_confirmed_purchase_order
        @purchase_order.quotation_id = @quotation.id
        @purchase_order.save!
      end
      
      should 'have one purchase_order associated' do
        assert_not_nil @quotation.purchase_order
      end
      
      should 'NOT be able to be associated with a purchase_order anymore' do
        assert !@quotation.can_be_associated_with_a_purchase_order?
      end
    end
  end
  
  context 'A sent quotation' do
    setup do
      @quotation = create_sent_quotation
    end
    
    subject{@quotation}
    
    should_not_allow_values_for :status, nil, Quotation::STATUS_SIGNED, Quotation::STATUS_SENT
    should_allow_values_for :status, Quotation::STATUS_CANCELLED
    
    should 'NOT have the drafted status' do
      assert !@quotation.drafted?
    end
    
    should 'NOT have the signed status' do
      assert !@quotation.signed?
    end
    
    should 'have the sent status' do
      assert @quotation.sent?
    end
    
    should 'NOT have the cancelled status' do
      assert !@quotation.cancelled?
    end
    
    should 'NOT have the drafted status in the database' do
      assert !@quotation.was_drafted?
    end
    
    should 'NOT have the signed status in the database' do
      assert !@quotation.was_signed?
    end
    
    should 'have the sent status in the database' do
      assert @quotation.was_sent?
    end
    
    should 'NOT have the cancelled status in the database' do
      assert !@quotation.was_cancelled?
    end
    
    should 'NOT be able to be signed' do
      assert !@quotation.can_be_signed?
    end
    
    should 'NOT be able to be sent' do
      assert !@quotation.can_be_sent?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'be able to be cancelled' do
      assert @quotation.can_be_cancelled?
    end
    
    should 'NOT be signed successfully' do
      assert !@quotation.sign
    end
    
    should 'NOT be sent successfully' do
      assert !@quotation.send_to_supplier
    end
    
    should 'be cancelled successfully with prerequisites' do
      @quotation.cancellation_comment = "Cancelled for tests"
      @quotation.canceller_id = users("admin_user").id
      assert @quotation.cancel
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
    
    should 'be able to be associated with a purchase_order' do
      assert @quotation.can_be_associated_with_a_purchase_order?
    end
    
    context 'associated with a purchase_order' do
      setup do
        @purchase_order = create_confirmed_purchase_order
        @purchase_order.quotation_id = @quotation.id
        @purchase_order.save!
      end
      
      should 'have one purchase_order associated' do
        assert @quotation.purchase_order
      end
      
      should 'NOT be able to be associated to a purchase_order anymore' do
        assert !@quotation.can_be_associated_with_a_purchase_order?
      end
      
      should 'NOT be able to be cancelled' do
        assert !@quotation.can_be_cancelled?
      end
    end
  end
  
  context 'A cancelled quotation' do
    setup do
      @quotation = create_cancelled_quotation
    end
    
    subject {@quotation}
    
    should_not_allow_values_for :status, Quotation::STATUS_CANCELLED
    should_allow_values_for :status, nil, Quotation::STATUS_SIGNED, Quotation::STATUS_SENT
    
    should 'NOT have the drafted status' do
      assert !@quotation.drafted?
    end
    
    should 'NOT have the signed status' do
      assert !@quotation.signed?
    end
    
    should 'NOT have the sent status' do
      assert !@quotation.sent?
    end
    
    should 'have the cancelled status' do
      assert @quotation.cancelled?
    end
    
    should 'NOT have the drafted status in the database' do
      assert !@quotation.was_drafted?
    end
    
    should 'NOT have the signed status in the database' do
      assert !@quotation.was_signed?
    end
    
    should 'NOT have the sent status in the database' do
      assert !@quotation.was_sent?
    end
    
    should 'have the cancelled status in the database' do
      assert @quotation.was_cancelled?
    end
    
    should 'be able to be drafted' do
      assert @quotation.can_be_drafted_from_cancelled?
    end
    
    should 'be able to be signed' do
      assert @quotation.can_be_signed?
    end
    
    should 'be able to be sent' do
      assert @quotation.can_be_sent?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation.can_be_edited?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@quotation.can_be_cancelled?
    end
    
    should 'NOT be able to be associated with a purchase_order' do
      assert !@quotation.can_be_associated_with_a_purchase_order?
    end
    
    should 'be signed successfully' do
      @quotation.signed_on = Date.today
      assert @quotation.sign      
    end
    
    should 'be sent successfully' do
      @quotation.signed_on = Date.today
      @quotation.sent_on = Date.today
      assert @quotation.send_to_supplier
    end
    
    should 'NOT be cancelled successfully' do
      assert !@quotation.cancel
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation.destroy
    end
  end
  
  context 'A revoked quotation' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation = @quotation_request.build_prefilled_quotation
      make_quotation_valid(@quotation)
      @quotation.save!
      
      supplier = create_supplier(thirds("second_supplier"))
      create_supplier_contact(supplier)
      
      @second_quotation_request = @quotation_request.build_prefilled_similar
      @second_quotation_request.supplier_id = supplier.id
      @second_quotation_request.supplier_contact_id = supplier.contacts.first.id
      @second_quotation_request.creator_id = users("admin_user").id
      @second_quotation_request.employee_id = employees("john_doe").id
      @second_quotation_request.save!
      
      @second_quotation = @second_quotation_request.build_prefilled_quotation
      make_quotation_valid(@second_quotation)
      
      @second_quotation.signed_on = Date.today
      flunk 'Failed to sign the @second_quotation' unless @second_quotation.sign
      @quotation.reload
      flunk 'Failed to revoke the @quotation' unless @quotation.revoked?
    end
    
    should 'NOT be able to be drafted back' do
      assert !@quotation.can_be_drafted_from_cancelled?
    end
    
    should 'NOT be able to be signed' do
      assert !@quotation.can_be_signed?
    end
    
    should 'NOT be able to be sent' do
      assert !@quotation.can_be_sent?
    end
    
    should 'revoke quotation requests related to @second_quotation' do
      assert @second_quotation.should_revoke_related_quotation_requests_and_quotations?
    end
  end
  
  context 'A quotation associated with a cancelled quotation_request' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation = @quotation_request.build_prefilled_quotation
      make_quotation_valid(@quotation)
      @quotation.save!
      
      @quotation_request.cancellation_comment = "Cancelled for tests"
      @quotation_request.canceller_id = users("admin_user").id
      flunk 'Cancellation of @quotation_request failed' unless @quotation_request.cancel
    end
    
#    TODO (not working)
#    should 'be revoked' do
#      assert @quotation.revoked?
#    end
  end
  
  context 'A quotation associated with a quotation_request' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation = @quotation_request.build_prefilled_quotation
      make_quotation_valid(@quotation)
      @quotation.save!
    end
    
    should 'have the same supplier_id than his quotation_request' do
      assert_equal @quotation.supplier_id, @quotation_request.supplier_id
    end
    
    context 'with a different supplier_id' do
      setup do
        @quotation.supplier_id = thirds("second_supplier").id
        @quotation.valid?
      end
      
      should 'invalid the supplier_id' do
        assert_match /Le fournisseur doit être le même que celui de la demande de devis associée./, @quotation.errors.on(:supplier_id)
      end
    end
  end
  
  context 'A quotation associated with inexisting supplier_supplies' do
    setup do
      @quotation = create_drafted_quotation
      build_quotation_supply_for(@quotation,  :supply_id => supplies("second_consumable").id,
                                              :quantity => 2000,
                                              :taxes => 10,
                                              :unit_price => 11,
                                              :prizegiving => 0,
                                              :designation => supplies("second_consumable").designation,
                                              :supplier_reference => "321654987",
                                              :supplier_designation => "Supplier Consumable")
      flunk 'Supplier_supply already exist' if SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, @quotation.quotation_supplies.last.supply_id)
      @quotation.save!
    end
    
    should 'have supplier_supplies created' do
      assert_not_nil SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, @quotation.quotation_supplies.first.supply_id)
    end
  end
  
  context 'A quotation with one quotation_supply built' do
    setup do
      @quotation = Quotation.new
      
      @quotation.creator_id = users("admin_user").id
      @quotation.supplier_id = thirds("first_supplier").id
      
      @quotation.build_quotation_document(:purchase_document => File.new(File.join(Test::Unit::TestCase.fixture_path, "quotation_document.gif")))
      flunk 'Already have quotation_supply' if @quotation.quotation_supplies(true).size != 0
      
      build_quotation_supply_for(@quotation,  :supply_id => supplies("first_commodity").id,
                                              :quantity => 1000,
                                              :taxes => 20,
                                              :unit_price => 15,
                                              :prizegiving => 0,
                                              :designation => supplies("first_commodity").designation,
                                              :supplier_reference => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_reference ,
                                              :supplier_designation => SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_designation)
      flunk 'Failed to build the quotation_supply' unless @quotation.quotation_supplies.size == 1
      @quotation.save!
      @quotation_supply = @quotation.quotation_supplies.first
    end
    
    should 'have a quotation_supply saved' do
      assert_equal 1, @quotation.quotation_supplies(true).size
    end
    
    should 'have a quotation_supply with the good supply_id' do
      assert_equal supplies("first_commodity").id, @quotation_supply.supply_id
    end
    
    should 'have a quotation_supply with the good quantity' do
      assert_equal 1000, @quotation_supply.quantity
    end
    
    should 'have a quotation_supply with the good taxes amount' do
      assert_equal 20, @quotation_supply.taxes
    end
    
    should 'have a quotation_supply with the good unit_price' do
      assert_equal 15, @quotation_supply.unit_price
    end
    
    should 'have a quotation_supply with the good prizegiving amount' do
      assert_equal 0, @quotation_supply.prizegiving
    end
    
    should 'have a quotation_supply with the good designation' do
      assert_match supplies("first_commodity").designation, @quotation_supply.designation
    end
    
    should 'have a quotation_supply with the good supplier_reference' do
      assert_match SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_reference, @quotation_supply.supplier_reference
    end
    
    should 'have a quotation_supply with the good supplier_designation' do
      assert_match SupplierSupply.find_by_supplier_id_and_supply_id(@quotation.supplier_id, supplies("first_commodity").id).supplier_designation, @quotation_supply.supplier_designation
    end
  end
end
