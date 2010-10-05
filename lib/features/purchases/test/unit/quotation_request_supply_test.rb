require File.dirname(__FILE__) + '/../purchases_test'

class QuotationRequestSupplyTest < ActiveSupport::TestCase
  should_have_many :quotation_request_purchase_request_supplies
  should_have_many :purchase_request_supplies
  
  should_belong_to :quotation_request, :supply
  
  context 'A quotation_request_supply with a supply_id' do
    setup do
      @quotation_request = QuotationRequest.new
      @quotation_request_supply = @quotation_request.quotation_request_supplies.build(:supply_id => supplies("first_commodity").id)
      flunk "Failed to build @quotation_request_supply" unless @quotation_request_supply
    end
    
    subject {@quotation_request_supply}
    
#    should_validate_presence_of :designation, :supply # ne fonctionne pas car assigné automatiquement si vide (demander à Mathieu si c'est nécessaire)
    should_validate_numericality_of :quantity
    
    should 'be an existing_supply' do
      assert @quotation_request_supply.existing_supply?
    end
    
    should 'NOT be a free_supply' do
      assert !@quotation_request_supply.free_supply?
    end
    
    should 'NOT be a comment_line' do
      assert !@quotation_request_supply.comment_line?
    end
    
    should 'have designation prefilled automatiquement' do
      assert_not_nil @quotation_request_supply.designation
    end
  end
  
  context 'A quotation_request_supply without supply_id and with comment_line set to false' do
    setup do
      @quotation_request = QuotationRequest.new
      @quotation_request_supply = @quotation_request.quotation_request_supplies.build
      flunk "Failed to build @quotation_request_supply" unless @quotation_request_supply
    end
    
    subject {@quotation_request_supply}
    
    should_validate_presence_of :designation
    should_validate_numericality_of :quantity
    
    should 'NOT be an existing_supply' do
      assert !@quotation_request_supply.existing_supply?
    end
    
    should 'be a free_supply' do
      assert @quotation_request_supply.free_supply?
    end
    
    should 'NOT be a comment_line' do
      assert !@quotation_request_supply.comment_line?
    end
    
    should 'NOT have desigation prefilled automatically' do
      assert_nil @quotation_request_supply.designation
    end
  end
  
  context 'A quotation_request_supply without a supply_id and with comment_line set to true' do
    setup do
      @quotation_request = QuotationRequest.new
      @quotation_request_supply = @quotation_request.quotation_request_supplies.build(:comment_line => true)
      flunk "Failed to build @quotation_request_supply" unless @quotation_request_supply
    end
    
    subject {@quotation_request_supply}
    
    should_validate_presence_of :name, :description
    
    should 'NOT be an existing_supply' do
      assert !@quotation_request_supply.existing_supply?
    end
    
    should 'NOT be a free_supply' do
      assert !@quotation_request_supply.free_supply?
    end
    
    should 'be a comment_line' do
      assert @quotation_request_supply.comment_line?
    end
    
    should 'NOT have desigation prefilled automatically' do
      assert_nil @quotation_request_supply.designation
    end
  end
  
  context 'An existing quotation_request_supply in a new quotation_request' do
    setup do
      @quotation_request = QuotationRequest.new
      @quotation_request.quotation_request_supplies.build(:supply_id => supplies("first_commodity").id)
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request_supply.can_be_destroyed?
    end
    
    should 'have a supply_id' do
      assert_not_nil @quotation_request_supply.supply_id
    end
    
    should 'NOT have a quantity' do
      assert_nil @quotation_request_supply.quantity
    end
    
    should 'NOT have a position' do
      assert_equal 0, @quotation_request_supply.position
    end
    
    should 'have a designation' do
      assert_not_nil @quotation_request_supply.designation
    end
    
    should 'NOT have a supplier_reference' do
      assert_nil @quotation_request_supply.supplier_reference
    end
    
    should 'NOT have a supplier_designation' do
      assert_nil @quotation_request_supply.supplier_designation
    end
    
    should 'NOT have a name' do
      assert_nil @quotation_request_supply.name
    end
    
    should 'have comment line set to false' do
      assert !@quotation_request_supply.comment_line
    end
    
    should 'NOT have a description' do
      assert_nil @quotation_request_supply.description
    end
  end
  
  context 'An existing quotation_request_supply in a drafted quotation_request' do
    setup do
      @quotation_request = create_drafted_quotation_request
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk "@quotation_request_supply is not an existing_supply" unless @quotation_request_supply.existing_supply?
      flunk 'Failed to build @quotation_request_supply' unless @quotation_request_supply
    end
    
    should 'be able to be destroyed' do
      assert @quotation_request_supply.can_be_destroyed?
    end
    
    should 'have a supplier_supply' do
      assert_not_nil SupplierSupply.find_by_supplier_id_and_supply_id(@quotation_request_supply.quotation_request.supplier_id, @quotation_request_supply.supply_id)
    end
    
    should 'have a supplier_reference' do
      assert_not_nil supplier_supplies("purchases_first_supplier_supply").supplier_reference, @quotation_request_supply.supplier_reference #créer une variable d'instance qui contient le supplier_supply
    end
    
    should 'have the good supplier_designation' do
      assert_match supplier_supplies("purchases_first_supplier_supply").supplier_designation, @quotation_request_supply.supplier_designation
    end
    
    context 'destroyed' do
      setup do
        @id = @quotation_request_supply.id
        flunk 'Failed to destroy the @quotation_request_supply' unless @quotation_request_supply.destroy
      end
      
      should 'NOT exist anymore' do
        assert QuotationRequestSupply.all(@id).empty?
      end
    end
    
    context 'with a purchase_request_supply associated' do
      setup do
        flunk 'Quotation_request_supply should not be associated with a purchase_request_supply' unless @quotation_request_supply.purchase_request_supplies.empty?
        
        @purchase_request = create_purchase_request(:purchase_request_supplies => [{:supply_id               => supplies("first_commodity").id,
                                                                                    :expected_quantity       => 30,
                                                                                    :expected_delivery_date  => Date.today + 1.week }] )
        
        flunk 'The purchase_request should have one purchase_request_supply' unless @purchase_request.purchase_request_supplies.size == 1
        fill_ids_with_identical_supply_ids(@quotation_request, @purchase_request)
        flunk 'Quotation_request_supply should have one purchase_request_supply associated' if @quotation_request_supply.purchase_request_supplies_ids.nil?
      end
      
      should 'have the purchase_request_supply id in its purchase_request_supplies_ids attributes' do
        assert_equal @purchase_request.purchase_request_supplies.first.id.to_s, @quotation_request_supply.purchase_request_supplies_ids.split("\;").first.to_s
      end
      
      context 'then saved' do
        setup do
          @quotation_request.save!
        end
        
        should 'be associated with the purchase_request_supply when the quotation_request is saved' do
          assert_equal @purchase_request.purchase_request_supplies.first.id, @quotation_request_supply.purchase_request_supplies.first.id
        end
      end
      
      context 'then dissociated' do
        setup do
          fill_ids_with_identical_supply_ids_for_deselection(@quotation_request, @purchase_request)
          flunk 'The quotation_request_supply do not have purchase_request_supplies_deselected_ids filled' unless @quotation_request_supply.purchase_request_supplies_deselected_ids
          @quotation_request.save!
        end

        should 'NOT be associated with the purchase_request_supply anymore' do
          assert @quotation_request_supply.purchase_request_supplies.empty?
        end
      end
    end
  end
  
  context 'A free quotation_request_supply in a drafted quotation_request' do
    setup do
      supplier = create_supplier
      create_supplier_contact(supplier)
      
      @quotation_request = QuotationRequest.new
      @quotation_request.creator_id = users("admin_user").id
      @quotation_request.supplier_id = supplier.id
      @quotation_request.supplier_contact_id = supplier.contacts.first.id
      build_free_quotation_request_supply(@quotation_request)
      @quotation_request.save!
      
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk 'Failed to build the quotation_request_supply' unless @quotation_request_supply
    end
    
    should 'NOT have supply_id' do
      assert_nil @quotation_request_supply.supply_id
    end
    
    should 'NOT have a supplier_supply' do
      assert_nil SupplierSupply.find_by_supplier_id_and_supply_id(@quotation_request_supply.quotation_request.supplier_id, @quotation_request_supply.supply_id)
    end
    
    should 'have comment line set to false' do
      assert !@quotation_request_supply.comment_line
    end
    
    should 'be able to be destroyed' do
      assert @quotation_request_supply.can_be_destroyed?
    end
    
    should 'respond false to existing_supply? method' do
      assert !@quotation_request_supply.existing_supply?
    end
    
    should 'respond true to free_supply? method' do
      assert @quotation_request_supply.free_supply?
    end
    
    should 'respond false to comment_line? method' do
      assert !@quotation_request_supply.comment_line?
    end
    
    should 'be destroyed successfully' do
      assert @quotation_request_supply.destroy
    end
  end
  
  context 'A comment line quotation_request_supply in a drafted quotation_request' do
    setup do
      supplier = create_supplier
      create_supplier_contact(supplier)
      
      @quotation_request = QuotationRequest.new
      @quotation_request.creator_id = users("admin_user").id
      @quotation_request.supplier_id = supplier.id
      @quotation_request.supplier_contact_id = supplier.contacts.first.id
      build_comment_line_for_quotation_request(@quotation_request)
      @quotation_request.save!
    
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk 'Failed to build the quotation_request_supply' unless @quotation_request_supply
    end
    
    subject {@quotation_request_supply}
    
    should 'NOT have supply_id' do
      assert_nil @quotation_request_supply.supply_id
    end
    
    should 'NOT have a supplier_supply' do
      assert_nil SupplierSupply.find_by_supplier_id_and_supply_id(@quotation_request_supply.quotation_request.supplier_id, @quotation_request_supply.supply_id)
    end
    
    should 'have comment line set to true' do
      assert @quotation_request_supply.comment_line
    end
    
    should 'have a name' do
      assert_not_nil @quotation_request_supply.name
    end
    
    should 'have a description' do
      assert_not_nil @quotation_request_supply.description
    end
    
    should 'NOT have a quantity' do
      assert_nil @quotation_request_supply.quantity
    end
    
    should 'have a position' do
      assert_not_nil @quotation_request_supply.position
    end
    
    should 'NOT have a designation' do
      assert_nil @quotation_request_supply.designation
    end
    
    should 'NOT have a supplier_reference' do
      assert_nil @quotation_request_supply.supplier_reference
    end
    
    should 'NOT have a supplier_designation' do
      assert_nil @quotation_request_supply.supplier_designation
    end
    
    should 'be able to be destroyed' do
      @quotation_request_supply.can_be_destroyed?
    end
    
    should 'be destroyed successfully' do
      @quotation_request_supply.destroy
    end

    should 'respond false to existing_supply? method' do
      @quotation_request_supply.existing_supply?
    end

    should 'respond false to free_supply? method' do
      @quotation_request_supply.free_supply?
    end

    should 'respond true to comment_line? method' do
      @quotation_request_supply.comment_line?
    end
  end
  
  context 'A quotation_request_supply in a confirmed quotation_request' do
    setup do
      @quotation_request = create_confirmed_quotation_request
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk "The quotation_request haven't quotation_request_supply" unless @quotation_request_supply
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request_supply.can_be_destroyed?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request_supply.destroy
    end
  end
  
  context 'A quotation_request_supply in a terminated quotation_request' do
    setup do
      @quotation_request = create_terminated_quotation_request
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk "The quotation_request haven't quotation_request_supply" unless @quotation_request_supply
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request_supply.can_be_destroyed?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request_supply.destroy
    end
  end
  
  context 'A quotation_request_supply in a cancelled quotation_request' do
    setup do
      @quotation_request = create_cancelled_quotation_request
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk "The quotation_request haven't quotation_request_supply" unless @quotation_request_supply
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request_supply.can_be_destroyed?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request_supply.destroy
    end
  end
  
  context 'A quotation_request_supply in a revoked quotation_request' do
    setup do
      @quotation_request = create_revoked_quotation_request
      @quotation_request_supply = @quotation_request.quotation_request_supplies.last
      flunk "The quotation_request haven't quotation_request_supply" unless @quotation_request_supply
    end
    
    should 'NOT be able to be destroyed' do
      assert !@quotation_request_supply.can_be_destroyed?
    end
    
    should 'NOT be destroyed successfully' do
      assert !@quotation_request_supply.destroy
    end
  end
end
