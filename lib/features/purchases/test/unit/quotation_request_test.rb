require File.dirname(__FILE__) + '/../purchases_test'

#TODO test has_permissions :as_business_object
#TODO test has_contact     has_contact :accept_from => :supplier_contacts, :required => true
#TODO test validates_contact_presence

class QuotationRequestTest < ActiveSupport::TestCase
  
  should_have_many :quotation_request_supplies
  should_have_many :children
  
  should_have_one :quotation
  should_have_one :quotation_document
  
  should_belong_to :supplier, :canceller, :creator, :employee, :parent, :similar
  
  should_validate_presence_of :creator, :supplier, :with_foreign_key => :default
  
  def init_creator_and_employee_and_supplier_and_supplier_contact(quotation_request, supplier)
    init_creator_and_employee(quotation_request)
    quotation_request.supplier_id = supplier.id
    quotation_request.supplier_contact_id = supplier.contacts.first.id
    quotation_request
  end
  
  def init_creator_and_employee(quotation_request)
    quotation_request.creator_id = users('admin_user').id
    quotation_request.employee_id = employees('john_doe').id
    quotation_request
  end
  
  context 'A new quotation_request' do
    setup do
      @quotation_request = QuotationRequest.new
      flunk 'quotation_request is not a new record' unless @quotation_request.new_record?
    end
    
    context 'without similars' do
      
      setup do
        flunk '@quotation_request should not have similars' if @quotation_request.similars.any?
      end
      
      subject {@quotation_request}
      
      should_not_allow_values_for :status, QuotationRequest::STATUS_CONFIRMED, QuotationRequest::STATUS_CANCELLED, QuotationRequest::STATUS_REVOKED
      should_allow_values_for :status, nil
    end

    should 'return false to drafted? method' do
      assert !@quotation_request.drafted?
    end
    
    should 'return false to confirmed? method' do
      assert !@quotation_request.confirmed?
    end
    
    should 'return false to terminated? method' do
      assert !@quotation_request.terminated?
    end
    
    should 'return false to cancelled? method' do
      assert !@quotation_request.cancelled?
    end
    
    should 'return false to revoked?' do
      assert !@quotation_request.revoked?
    end
    
    should 'return false to was_drafted? method' do
      assert !@quotation_request.was_drafted?
    end
    
    should 'return false to was_confirmed? method' do
      assert !@quotation_request.was_confirmed?
    end
    
    should 'return false to was_terminated? method' do
      assert !@quotation_request.was_terminated?
    end
    
    should 'return false to was_cancelled? method' do
      assert !@quotation_request.was_cancelled?
    end

    should 'return false to was_revoked? method' do
      assert !@quotation_request.was_revoked?
    end
    
    should 'NOT be able to be confirmed' do
      assert !@quotation_request.can_be_confirmed?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation_request.can_be_edited?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@quotation_request.can_be_cancelled?
    end
    
    should 'NOT be able to be revoked' do
      assert !@quotation_request.can_be_revoked?
    end
    
    should 'NOT be able to be sent to another supplier' do
      assert !@quotation_request.can_be_sent_to_another_supplier?
    end
    
    should 'NOT be confirmed successfully without prequisites' do
      assert !@quotation_request.confirm
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@quotation_request.cancel
    end
    
    should 'NOT be able to revoke successfully' do
      assert !@quotation_request.revoke
    end
    
    should 'require at least one quotation_request_supply' do
      @quotation_request.valid?
      assert_match /Vous devez entrer au moins une fourniture/, @quotation_request.errors.on(:quotation_request_supplies)
    end
    
    context 'with a quotation_request_supply' do
      setup do
        @quotation_request_supply = build_existing_quotation_request_supply(@quotation_request)
        flunk 'The quotation_request_supply is invalid' unless @quotation_request_supply.valid?
      end
      
      should 'have a valid quotation_request_supplies' do
        assert_nil @quotation_request.errors.on(:quotation_request_supplies)
      end
      
      context 'associated to a purchase_request_supply' do
        setup do
          supplier = create_supplier
          
          @quotation_request.creator_id = users('admin_user').id
          @quotation_request.supplier_id = supplier.id
          @quotation_request.supplier_contact_id = supplier.contacts.first.id
          flunk 'Supplier undefined' unless @quotation_request.supplier
          
          @quotation_request.employee_id = employees('john_doe').id
          flunk 'Quotation_request_supplies number is not equal to 1' unless @quotation_request.quotation_request_supplies.size == 1
          
          @purchase_request = create_purchase_request
          fill_ids_with_identical_supply_ids(@quotation_request, @purchase_request)
          flunk 'The quotation_request_supply do not have purchase_request_supplies_ids filled' unless @quotation_request.quotation_request_supplies.first.purchase_request_supplies_ids
          @quotation_request.save!
        end
        
        should 'have one purchase_request_supply associated' do
          assert_equal 1, @quotation_request.quotation_request_supplies.first.purchase_request_supplies.size
        end
        
        context 'then dissociated' do
          setup do
            fill_ids_with_identical_supply_ids_for_deselection(@quotation_request, @purchase_request)
            flunk 'The quotation_request_supply do not have purchase_request_supplies_deselected_ids filled' unless @quotation_request.quotation_request_supplies.first.purchase_request_supplies_deselected_ids
            @quotation_request.save!
          end
          
          should 'NOT have purchase_request_supplies associated anymore' do
            assert !@quotation_request.quotation_request_supplies.detect{ |qrs| qrs.purchase_request_supplies.any? }
          end
        end
      end
    end
  end
  
  context 'A new similar quotation_request' do
    setup do
      @first_quotation_request = create_confirmed_quotation_request(:quotation_request_supplies_attributes => [ { :quantity => 1000,
                                                                                                                  :supply_id => supplies("first_commodity").id,
                                                                                                                  :designation => supplies("first_commodity").name },
                                                                                                                { :quantity => 500,
                                                                                                                  :supply_id => supplies("first_commodity").id,
                                                                                                                  :designation => supplies("first_commodity").name } ])
      @second_quotation_request = @first_quotation_request.build_prefilled_similar
      flunk 'Failed to build quotation_request' unless @second_quotation_request
      second_supplier = create_supplier(thirds('second_supplier'))
      @second_quotation_request.creator_id = users('admin_user').id
      @second_quotation_request.supplier_id = second_supplier.id
      @second_quotation_request.supplier_contact_id = second_supplier.contacts.first.id
      flunk '@second_quotation_request.supplier is not different than @first_quotation_request' unless @second_quotation_request.supplier_id != @first_quotation_request.supplier_id
      @second_quotation_request.employee_id = employees('john_doe').id
    end
    
    subject {@second_quotation_request}
    
#    should_not_allow_values_for :status, QuotationRequest::STATUS_CANCELLED, QuotationRequest::STATUS_REVOKED, nil
#    should_allow_values_for :status, QuotationRequest::STATUS_CONFIRMED
    
    should 'have the first quotation_request as similar' do
      assert_equal @first_quotation_request.id, @second_quotation_request.similar_id
    end
    
    context 'with the same supplier than its similar' do
      setup do
        @second_quotation_request.supplier_id = @first_quotation_request.supplier_id
        @second_quotation_request.valid?
      end
      
      should 'invalid supplier_id' do
        assert_match /Cette demande de devis existe déjà pour ce fournisseur, veuillez choisir un autre fournisseur/, @second_quotation_request.errors.on(:supplier_id)
      end
    end
    
    context 'with a difference of quantity in the quotation_request_supply of the second quotation_request' do
      setup do
        @second_quotation_request.quotation_request_supplies.first.quantity = 999
        flunk "Quantities are not different" unless @first_quotation_request.quotation_request_supplies.first.quantity != @second_quotation_request.quotation_request_supplies.first.quantity
        @second_quotation_request.valid?
      end
      
      should 'invalid quotation_request_supplies' do
        assert_match /La demande de devis n'est pas similaire à celle prise comme modèle/, @second_quotation_request.errors.on(:quotation_request_supplies)
      end
    end

    context 'with a missing quotation_request_supply in the second quotation_request' do
      setup do
        flunk 'Failed to destroy the quotation_request_supply' unless @second_quotation_request.quotation_request_supplies.pop
        @second_quotation_request.valid?
      end
  
      should 'invalid quotation_request_supplies' do
        assert_match /La demande de devis n'est pas similaire à celle prise comme modèle/, @second_quotation_request.errors.on(:quotation_request_supplies)
      end
    end
    
    context 'with an additional quotation_request_supply in the second quotation_request' do
      setup do
        build_existing_quotation_request_supply(@second_quotation_request, :designation => supplies('first_consumable').name, :supply_id => supplies('first_consumable').id)
        @second_quotation_request.valid?
      end
  
      should 'invalid quotation_request_supplies' do
        assert_match /La demande de devis n'est pas similaire à celle prise comme modèle/, @second_quotation_request.errors.on(:quotation_request_supplies)
      end
    end
    
    context 'then when the similar quotation_request saved' do
      setup do
        @second_quotation_request.save!
        @first_quotation_request.reload
      end

      should 'return true to confirmed? method' do
        assert @second_quotation_request.confirmed?
      end

      should 'be the in the list of similars of the first quotation_request' do
        assert_equal @second_quotation_request, @first_quotation_request.similars.first
      end
    end

    context 'and then a quotation_request built by reviewing the confirmed one, the reviewed quotation_request' do
      setup do
        @reviewed_quotation_request = @first_quotation_request.build_prefilled_child
        flunk 'Failed to build reviewed quotation_request' unless @reviewed_quotation_request
        flunk 'Parent item don\'t feat with child item' unless @first_quotation_request.quotation_request_supplies.first.supply_id == @reviewed_quotation_request.quotation_request_supplies.first.supply_id and @first_quotation_request.quotation_request_supplies.first.quantity == @reviewed_quotation_request.quotation_request_supplies.first.quantity and @first_quotation_request.quotation_request_supplies.first.position == @reviewed_quotation_request.quotation_request_supplies.first.position  and @first_quotation_request.quotation_request_supplies.first.name == @reviewed_quotation_request.quotation_request_supplies.first.name and @first_quotation_request.quotation_request_supplies.first.description == @reviewed_quotation_request.quotation_request_supplies.first.description and @first_quotation_request.quotation_request_supplies.first.comment_line == @reviewed_quotation_request.quotation_request_supplies.first.comment_line and @first_quotation_request.quotation_request_supplies.first.designation == @reviewed_quotation_request.quotation_request_supplies.first.designation
        @reviewed_quotation_request.creator_id = users('admin_user').id
        flunk 'Parent is not good' unless @reviewed_quotation_request.parent_id == @first_quotation_request.id
        flunk 'Parent supplier is not the same than first quotation_request' unless @first_quotation_request.supplier_id == @reviewed_quotation_request.supplier_id
      end

      subject {@reviewed_quotation_request}

      should_not_allow_values_for :status, QuotationRequest::STATUS_CANCELLED, QuotationRequest::STATUS_REVOKED, QuotationRequest::STATUS_CONFIRMED
      should_allow_values_for :status, nil

      should 'have quotation_request as parent' do
        assert @reviewed_quotation_request.parent_id == @first_quotation_request.id
      end

      should 'NOT be able to be cancelled' do
        assert !@reviewed_quotation_request.can_be_cancelled?
      end

      should 'NOT be cancelled successfully' do
        assert !@reviewed_quotation_request.cancel
      end
    end
  end
  
  context 'Four quotation_requests related by parental links or similarity links and which one is terminated' do
    setup do
      @base_quotation_request = create_confirmed_quotation_request
      flunk 'Should not be revoked' if @base_quotation_request.was_revoked?
      
      second_supplier = create_supplier(thirds('second_supplier'))
      @similar_quotation_request = @base_quotation_request.build_prefilled_similar
      init_creator_and_employee_and_supplier_and_supplier_contact(@similar_quotation_request, second_supplier)
      @similar_quotation_request.save!
      flunk 'Should not be revoked' if @similar_quotation_request.was_revoked?

      @reviewed_quotation_request = @base_quotation_request.build_prefilled_child
      init_creator_and_employee(@reviewed_quotation_request)
      @reviewed_quotation_request.save!
      flunk 'Should not be revoked' if @reviewed_quotation_request.was_revoked?

      @reviewed_similar_quotation_request = @similar_quotation_request.build_prefilled_child
      init_creator_and_employee(@reviewed_similar_quotation_request)
      @reviewed_similar_quotation_request.save!
      flunk 'Should not be revoked' if @reviewed_similar_quotation_request.was_revoked?
      
      flunk 'Similar quotation_request failed to confirm' unless @reviewed_similar_quotation_request.confirm

      @base_quotation_request.reload
      @similar_quotation_request.reload
      @reviewed_quotation_request.reload
      @reviewed_similar_quotation_request.reload

      @quotation = @reviewed_similar_quotation_request.build_prefilled_quotation
      make_quotation_valid(@quotation)

      sign_quotation(@quotation)
      @base_quotation_request.reload
      @similar_quotation_request.reload
      @reviewed_quotation_request.reload
      @reviewed_similar_quotation_request.reload
      flunk 'The quotation_request associated to the signed quotation didn\'t passed to terminated' unless @reviewed_similar_quotation_request.was_terminated?
    end
    
    should 'have the base quotation_request revoked' do
      assert @base_quotation_request.was_revoked?
    end
    
    should 'have the similar quotation_request revoked' do
      assert @similar_quotation_request.was_revoked?
    end

    should 'have the modified quotation_request revoked' do
      assert @reviewed_quotation_request.was_revoked?
    end
  end
  
  context 'A drafted quotation_request' do
    setup do
      @quotation_request = create_drafted_quotation_request
    end
    
    subject {@quotation_request}
    
    should_not_allow_values_for :status, QuotationRequest::STATUS_CANCELLED
    should_allow_values_for :status, QuotationRequest::STATUS_CONFIRMED, QuotationRequest::STATUS_REVOKED, nil
    
    should 'return true to drafted? method' do
      assert @quotation_request.drafted?
    end
    
    should 'return false to confirmed? method' do
      assert !@quotation_request.confirmed?
    end
    
    should 'return false to terminated? method' do
      assert !@quotation_request.terminated?
    end
    
    should 'return false to cancelled? method' do
      assert !@quotation_request.cancelled?
    end
    
    should 'return true to was_drafted? method' do
      assert @quotation_request.was_drafted?
    end
    
    should 'return false to was_confirmed? method' do
      assert !@quotation_request.was_confirmed?
    end
    
    should 'return false to was_terminated? method' do
      assert !@quotation_request.was_terminated?
    end
    
    should 'return false to was_cancelled? method' do
      assert !@quotation_request.was_cancelled?
    end

    should 'be able to be confirmed' do
      assert @quotation_request.can_be_confirmed?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@quotation_request.can_be_cancelled?
    end
    
    should 'be able to be destroyed' do
      assert @quotation_request.can_be_destroyed?
    end
    
    should 'be able to be edited' do
      assert @quotation_request.can_be_edited?
    end
    
    should 'NOT be able to be sent to another supplier' do
      assert !@quotation_request.can_be_sent_to_another_supplier?
    end
    
    should 'NOT be confirmed successfully without employee_id' do
      assert !@quotation_request.confirm
    end
    
    should 'NOT be cancelled successfully' do
      assert !@quotation_request.cancel
    end
    
    should 'be destroyed successfully' do
      assert @quotation_request.destroy
    end
    
    context 'while confirmation' do
      setup do
        build_existing_quotation_request_supply(@quotation_request)
        flunk 'Failed to create quotation_request_supply' unless @quotation_request_supply = @quotation_request.quotation_request_supplies.first
        prepare_quotation_request_to_be_confirmed(@quotation_request)
      end

      subject {@quotation_request}

      should_validate_presence_of :reference, :employee_id

      should 'be able to be confirmed' do
        assert @quotation_request.can_be_confirmed?
      end
      
      should 'be confirmed successfully' do 
        assert @quotation_request.confirm
      end
    end
  end

  context 'A confirmed quotation_request' do
    setup do
      @quotation_request = create_confirmed_quotation_request
    end

    subject {@quotation_request}

    should_not_allow_values_for :status, QuotationRequest::STATUS_CONFIRMED
    should_allow_values_for :status, QuotationRequest::STATUS_CANCELLED, QuotationRequest::STATUS_REVOKED, nil
    
    should 'return false to drafted? method' do
      assert !@quotation_request.drafted?
    end
    
    should 'return true to confirmed? method' do
      assert @quotation_request.confirmed?
    end
    
    should 'return false to terminated? method' do
      assert !@quotation_request.terminated?
    end
    
    should 'return false to cancelled? method' do
      assert !@quotation_request.cancelled?
    end

    should 'return false to revoked? method' do
      assert !@quotation_request.revoked?
    end

    should 'return false to was_drafted? method' do
      assert !@quotation_request.was_drafted?
    end
    
    should 'return true to was_confirmed? method' do
      assert @quotation_request.was_confirmed?
    end
    
    should 'return false to was_terminated? method' do
      assert !@quotation_request.was_terminated?
    end
    
    should 'return false to was_cancelled? method' do
      assert !@quotation_request.was_cancelled?
    end

    should 'return false to was_revoked? method' do
      assert !@quotation_request.was_revoked?
    end
    
    should 'NOT be able to be confirmed' do
      assert !@quotation_request.can_be_confirmed?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation_request.can_be_edited?
    end
    
    should 'be able to be cancelled' do
      assert @quotation_request.can_be_cancelled?
    end

    should 'be able to be revoked' do
      assert @quotation_request.can_be_revoked?
    end
    
    should 'be able to be sent to another supplier' do
      assert @quotation_request.can_be_sent_to_another_supplier?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@quotation_request.confirm
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@quotation_request.cancel
    end

    should 'be revoked successfully' do
      assert @quotation_request.revoke
    end
    
    context 'while cancellation' do
      setup do
        @quotation_request.cancellation_comment = 'Cancelled for tests'
        @quotation_request.canceller_id = users('admin_user').id
        @quotation_request.cancelled_at = Time.now
        @quotation_request.status = QuotationRequest::STATUS_CANCELLED
      end
      
      should 'be able to be cancelled' do
        assert @quotation_request.can_be_cancelled?
      end
      
      should 'be cancelled successfully' do
        assert @quotation_request.save!
      end
    end
    
    context 'while termination' do
      setup do
        create_signed_quotation_from(@quotation_request)
      end
      
      should 'respond true to terminated? method' do
        assert @quotation_request.terminated?
      end
    end
  end
  
  context 'A terminated quotation_request' do
    setup do
      @quotation_request = create_terminated_quotation_request
    end
    
    subject {@quotation_request}
    
    should_not_allow_values_for :status, nil, QuotationRequest::STATUS_CONFIRMED, QuotationRequest::STATUS_REVOKED
    should_allow_values_for :status, QuotationRequest::STATUS_CANCELLED
    
    should 'return false to drafted? method' do
      assert !@quotation_request.drafted?
    end
    
    should 'return false to confirmed? method' do
      assert !@quotation_request.confirmed?
    end
    
    should 'return true to terminated? method' do
      assert @quotation_request.terminated?
    end
    
    should 'return false to cancelled? method' do
      assert !@quotation_request.cancelled?
    end

    should 'return false to revoked? method' do
      assert !@quotation_request.revoked?
    end
    
    should 'return false to was_drafted? method' do
      assert !@quotation_request.was_drafted?
    end
    
    should 'return false to was_confirmed? method' do
      assert !@quotation_request.was_confirmed?
    end
    
    should 'return true to was_terminated? method' do
      assert @quotation_request.was_terminated?
    end
    
    should 'return false to was_cancelled? method' do
      assert !@quotation_request.was_cancelled?
    end

    should 'return false to was_revoked? method' do
      assert !@quotation_request.was_revoked?
    end
    
    should 'NOT be able to be confirmed' do
      assert !@quotation_request.can_be_confirmed?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation_request.can_be_edited?
    end
    
    should 'be able to be cancelled' do
      assert @quotation_request.can_be_cancelled?
    end

    should 'NOT be able to be revoked?' do
      assert !@quotation_request.can_be_revoked?
    end
    
    should 'NOT be able to be sent to another supplier' do
      assert !@quotation_request.can_be_sent_to_another_supplier?
    end
    
    should 'NOT be confirmed successfully' do
      assert !@quotation_request.confirm
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request.destroy
    end
    
    should 'NOT be cancelled successfully' do
      @quotation_request.canceller_id = users('admin_user').id
      @quotation_request.cancellation_comment = 'Cancelled for tests'
      assert !@quotation_request.cancel
    end

    should 'NOT be revoked successfully' do
      assert !@quotation_request.revoke
    end

    should 'have all related quotation_requests revoked' do
      assert !@quotation_request.related_quotation_requests.detect{ |qr| !qr.revoked? }
    end
    
    context 'after quotation cancellation' do
      setup do
        @quotation_request.quotation.canceller_id = users('admin_user').id
        @quotation_request.quotation.cancellation_comment = 'Cancelled for tests'
        flunk 'Failed to cancel the quotation' unless @quotation_request.quotation.cancel
        @quotation_request.reload
      end

#       TODO not working yet
#      should 'have status to revoked' do
#        assert @quotation_request.was_revoked?
#      end

      should 'have cancelled associated quotation' do
        assert @quotation_request.quotation(true).was_cancelled?
      end
    end
  end
  
  context 'A cancelled quotation_request' do
    setup do
      @quotation_request = create_cancelled_quotation_request
    end
    
    subject {@quotation_request}
    
    should_not_allow_values_for :status, QuotationRequest::STATUS_REVOKED, QuotationRequest::STATUS_CANCELLED
    should_allow_values_for :status, QuotationRequest::STATUS_CONFIRMED, nil
    
    should 'return false to drafted? method' do
      assert !@quotation_request.drafted?
    end
    
    should 'return false to confirmed? method' do
      assert !@quotation_request.confirmed?
    end
    
    should 'return false to terminated? method' do
      assert !@quotation_request.terminated?
    end
    
    should 'return true to cancelled? method' do
      assert @quotation_request.cancelled?
    end

    should 'return false to revoked? method' do
      assert !@quotation_request.revoked?
    end
    
    should 'return false to was_drafted? method' do
      assert !@quotation_request.was_drafted?
    end
    
    should 'return false to was_confirmed? method' do
      assert !@quotation_request.was_confirmed?
    end
    
    should 'return false to was_terminated? method' do
      assert !@quotation_request.was_terminated?
    end
    
    should 'return true to was_cancelled? method' do
      assert @quotation_request.was_cancelled?
    end

    should 'return false to was_revoked? method' do
      assert !@quotation_request.was_revoked?
    end
    
    should 'be able to be confirmed' do
      assert @quotation_request.can_be_confirmed?
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request.can_be_destroyed?
    end
    
    should 'NOT be able to be edited' do
      assert !@quotation_request.can_be_edited?
    end
    
    should 'NOT be able to be cancelled' do
      assert !@quotation_request.can_be_cancelled?
    end

    should 'NOT be able to be revoked' do
      assert !@quotation_request.can_be_revoked?
    end
    
    should 'NOT be able to be sent to another supplier' do
      assert !@quotation_request.can_be_sent_to_another_supplier?
    end
    
    should 'be confirmed successfully' do
      assert @quotation_request.confirm
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request.destroy
    end
    
    should 'NOT be cancelled successfully' do
      assert !@quotation_request.cancel
    end

    should 'NOT be able to revoke successfully' do
      assert !@quotation_request.revoke
    end

    context 'after confirmation' do
      setup do
        flunk 'Failed to confirm quotation_request' unless @quotation_request.confirm
      end

      should 'have cancellation attributes reset' do
        assert !@quotation_request.cancellation_comment and !@quotation_request.canceller_id
      end

      should 'respond true to was_confirmed? method' do
        assert @quotation_request.was_confirmed?
      end

      should 'respond true to confirmed? method' do
        assert @quotation_request.confirmed?
      end
    end
  end

  context 'A revoked quotation_request' do
    setup do
      @quotation_request = create_revoked_quotation_request
    end

    should 'respond false to drafted? method' do
      assert !@quotation_request = @quotation_request.drafted?
    end

    should 'respond false to confirmed? method' do
      assert !@quotation_request = @quotation_request.confirmed?
    end

    should 'respond false to terminated? method' do
      assert !@quotation_request = @quotation_request.terminated?
    end

    should 'respond false to cancelled? method' do
      assert !@quotation_request = @quotation_request.cancelled?
    end

    should 'NOT be able to be confirmed' do
      assert !@quotation_request.can_be_confirmed?
    end

    should 'NOT be able to be cancelled' do
      assert !@quotation_request.can_be_cancelled?
    end

    should 'NOT be able to be destroyed' do
      assert !@quotation_request.can_be_destroyed?
    end
    
    should 'NOT be able to be reviewed' do
      assert !@quotation_request.can_be_reviewed?
    end
  end
  
  context 'A quotation_request associated to a quotation' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation = @quotation_request.build_prefilled_quotation
      make_quotation_valid(@quotation)
      @quotation.save!
    end
    
    should 'be able to be reviewed' do
      assert @quotation_request.can_be_reviewed?
    end
    
    context 'then revoked by the quotation cancellation' do
      setup do
        @quotation.cancellation_comment = "Cancelled for tests"
        @quotation.canceller_id = users("admin_user").id
        flunk 'Failed to cancel the quotation' unless @quotation.cancel
        @quotation_request.reload
      end
      
#      TODO not working
#      should 'be revoked' do
#        assert @quotation_request.revoked?
#      end
      
      should 'be able to be reviewed' do
        assert @quotation_request.can_be_reviewed?
      end
      
      should 'build prefilled child from @quotation_request' do
        assert_not_nil @quotation_request.build_prefilled_child
      end
    end
  end
end
