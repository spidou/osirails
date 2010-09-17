require File.dirname(__FILE__) + '/../sales_test'
 
class DeliveryNoteTest < ActiveSupport::TestCase
  #TODO test has_permissions :as_business_object
  #TODO test has_address     :ship_to_address
  #TODO test has_contact     :accept_from => :order_and_customer_contacts
  
  should_have_attached_file :attachment
  
  should_belong_to :order, :creator, :delivery_note_type
  
  should_have_many :delivery_note_items, :dependent => :destroy
  should_have_many :quote_items,         :through   => :delivery_note_items
  
  should_have_many :delivery_interventions
  should_have_one  :pending_delivery_intervention
  should_have_one  :delivered_delivery_intervention
  
  should_validate_presence_of :delivery_note_items, :ship_to_address
  should_validate_presence_of :order, :creator, :delivery_note_type, :delivery_note_contact, :with_foreign_key => :default
  
  should_not_allow_values_for :status, 0, 1, 100, "string"
  should_allow_values_for :status, nil, DeliveryNote::STATUS_CONFIRMED, DeliveryNote::STATUS_CANCELLED
  
  should_not_allow_mass_assignment_of :status, :reference, :confirmed_at, :cancelled_at
  
  context "In an order WITHOUT a signed quote" do
    #TODO assert a new delivery_note cannot be added
  end
  
  context "In an order with a signed quote and 1 'full' delivery_note" do
    #TODO assert a new delivery_note cannot be added if delivery_note is uncomplete, confirmed or signed
  end
  
  context "In an order with a signed quote" do
    setup do
      @order = create_default_order
      @signed_quote = create_signed_quote_for(@order)
      
      @invalid_address = Address.new # assuming Address.new returns an invalid record by default
      @valid_address = Address.new(:street_name       => "Street Name",
                                   :country_name      => "Country",
                                   :city_name         => "City",
                                   :zip_code          => "01234",
                                   :has_address_type  => "DeliveryNote",
                                   :has_address_key   => "ship_to_address")
      
      @attachment = File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_note_attachment.pdf"))
      
      flunk "@valid_address should be valid"       unless @valid_address.valid?
      flunk "@invalid_address should NOT be valid" if @invalid_address.valid?
    end
    
    teardown do
      @order = @signed_quote = @attachment = nil
      @invalid_address = @valid_address = nil
    end
    
    #TODO this context have been adapted from old code, but it should be reviewed to be adapted for the real shoulda way to write test
    context "a new and empty delivery_note" do
      setup do
        @dn = @order.delivery_notes.build # the object must be clear to perform the test, so don't add any attributes on that object
        @dn.valid?
      end
      
      teardown do
        @dn = nil
      end
      
      should "be able to be added" do
        assert @dn.can_be_added?, "@dn.order.all_is_delivered_or_scheduled? => #{@dn.order.all_is_delivered_or_scheduled?}"
      end
    
      should "have a ship_to_address" do
        assert @dn.errors.invalid?(:ship_to_address), "ship_to_address should NOT be a valid because it's nil"
      
        @dn.ship_to_address = @invalid_address
        @dn.valid?
        assert @dn.errors.invalid?(:ship_to_address), "ship_to_address should NOT be valid"
        
        @dn.ship_to_address = @valid_address
        @dn.valid?
        assert !@dn.errors.invalid?(:ship_to_address), "ship_to_address should be valid"
      end
      
      should "have an associated quote" do
        assert_not_nil @dn.associated_quote, "delivery_note should have an associated_quote"
        assert @dn.associated_quote.instance_of?(Quote), "associated_quote should be an instance of Quote"
      end
      
      #TODO these tests should be in delivery_note_item_test.rb
      should "have valid delivery_note_items" do
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because it's empty"
        
        # when a quote_item_id is wrong
        @dn.delivery_note_items.build(:quote_item_id => 0)
        @dn.valid?
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because quote_item_id is wrong"
        assert !@dn.delivery_note_items.first.errors.invalid?(:quote_item_id), "quote_item_id should be valid"
        assert @dn.delivery_note_items.first.errors.invalid?(:quote_item), "quote_item should NOT be valid because quote_item_id is wrong"
        
        # when a quote_item is invalid
        @dn.delivery_note_items = []
        @dn.delivery_note_items.build.quote_item = QuoteItem.new # assuming QuoteItem.new returns an invalid record
        @dn.valid?
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because quote_item is invalid"
        assert @dn.delivery_note_items.first.errors.invalid?(:quote_item_id), "quote_item_id should NOT be valid because it's an invalid record"
        
        # when a quantity is not in range
        @dn.delivery_note_items.first.quantity = @dn.associated_quote.quote_items.first.quantity + 1
        @dn.valid?
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because quantity is out of range (too big)"
        assert @dn.delivery_note_items.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's out of range (too big)"
        
        @dn.delivery_note_items.first.quantity = -1
        @dn.valid?
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because quantity is out of range (too small)"
        assert @dn.delivery_note_items.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's out of range (too small)"
        
        # when a quantity is not a number
        @dn.delivery_note_items.first.quantity = "not a number"
        @dn.valid?
        assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because quantity is not a number"
        assert @dn.delivery_note_items.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's not a number"
        
        # when all is ok
        @dn.delivery_note_items = []
        @dn.associated_quote.quote_items.each do |ref|
          @dn.delivery_note_items.build(:quote_item_id => ref.id, :quantity => ref.quantity)
        end
        assert_equal @dn.associated_quote.quote_items.size,
                     @dn.delivery_note_items.size, "delivery_note_items should be at the good size"
        @dn.valid?
        assert !@dn.errors.invalid?(:delivery_note_items), "delivery_note_items should be valid"
      end
      
      should "have a valid status" do
        @dn = create_valid_delivery_note_for(@order)
        
        assert_nil @dn.status, "@dn.status should be nil"
        assert @dn.uncomplete?, "delivery_note should be uncomplete"
        @dn.valid?
        assert !@dn.errors.invalid?(:status), "status should be valid"
      end
    end
    
    
    context "an UNCOMPLETE delivery note" do
      setup do
        @dn = create_valid_delivery_note_for(@order)
        
        @dn.valid?
        flunk "@dn should be uncomplete" unless @dn.was_uncomplete?
      end
      
      teardown do
        @dn = nil
      end
      
      should "have a good 'status' value" do
        assert_equal nil, @dn.status
      end
      
      should "be able to be edited " do
        assert @dn.can_be_edited?
      end
      
      should "be updated successfully" do
        assert_creator_id_cannot_be_updated
        assert_ship_to_address_can_be_updated
        assert_delivery_note_contact_can_be_updated
        assert_delivery_note_items_can_be_updated
      end
      
      should "be able to be deleted" do
        assert @dn.can_be_destroyed?
      end
      
      should "be deleted successfully" do
        assert @dn.destroy
      end
      
      should "be able to be confirmed" do
        assert @dn.can_be_confirmed?
      end
      
      should "be confirmed successfully" do
        assert @dn.confirm
      end
      
      should "be able to be cancelled" do
        assert @dn.can_be_cancelled?
      end
      
      should "be cancelled successfully" do
        assert @dn.cancel
      end
      
      should "be able to be scheduled" do
        assert @dn.can_be_scheduled?
      end
      
      should "be scheduled successfully" do
        intervention = build_valid_delivery_intervention_for(@dn)
        assert intervention.save, intervention.errors.inspect
        assert @dn.pending_delivery_intervention
      end
      
      should "NOT be able to be realized" do
        assert !@dn.can_be_realized?
      end
      
      should "NOT be realized successfully" do
        #TODO
      end
      
      should "NOT be able to be signed" do
        assert !@dn.can_be_signed?
      end
      
      #should "NOT be signed successfully" do
      #end
      
      context "(with a pending_delivery_intervention)" do
        setup do
          @intervention = create_scheduled_delivery_intervention_for(@dn)
          @dn.reload
          
          flunk "@intervention should be saved" if @intervention.new_record?
          flunk "@dn should have a pending_delivery_intervention" unless @dn.pending_delivery_intervention
        end
      
        teardown do
          @intervention = nil
        end
        
        should "be able to be scheduled" do
          assert @dn.can_be_scheduled?
        end
        
        should "edit pending_delivery_intervention successfully" do
          #TODO
        end
        
        should "NOT create another delivery_intervention" do
          #TODO
        end
        
        should "be able to be realized" do
          assert @dn.can_be_realized?
        end
        
        should "be realized successfully" do
          #TODO
        end
      end
    end
    
    
    context "a CONFIRMED delivery note" do
      setup do
        @dn = create_valid_delivery_note_for(@order)
        confirm_delivery_note(@dn)
        
        @dn.valid?
        flunk "@dn should be confirmed" unless @dn.was_confirmed?
        flunk "delivery_note should NOT have a pending delivery_intervention" unless @dn.pending_delivery_intervention.nil?
      end
      
      teardown do
        @dn = nil
      end
      
      subject{ @dn }
      
      should_not_allow_values_for :status, 0, 1, 100, "string", nil, DeliveryNote::STATUS_CONFIRMED
      should_allow_values_for :status, DeliveryNote::STATUS_CANCELLED, DeliveryNote::STATUS_SIGNED
      
      should "have a good 'status' value" do
        assert_equal DeliveryNote::STATUS_CONFIRMED, @dn.status
      end
      
      should "NOT be able to be edited " do
        assert !@dn.can_be_edited?
      end
      
      should "NOT be updated successfully" do
        assert_creator_id_cannot_be_updated
        assert_ship_to_address_cannot_be_updated
        assert_delivery_note_contact_cannot_be_updated
        assert_delivery_note_items_cannot_be_updated
      end
      
      should "NOT be able to be destroyed" do
        assert !@dn.can_be_destroyed?
      end
      
      should "NOT be deleted successfully" do
        assert !@dn.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@dn.can_be_confirmed?
      end
      
      should "NOT be confirmed successfully" do
        assert !@dn.confirm
      end
      
      should "be able to be cancelled" do
        assert @dn.can_be_cancelled?
      end
      
      should "be cancelled successfully" do
        assert @dn.cancel
      end
      
      should "be able to be scheduled" do
        assert @dn.can_be_scheduled?
      end
      
      should "be scheduled successfully" do
        intervention = build_valid_delivery_intervention_for(@dn)
        assert intervention.save, intervention.errors.inspect
        assert DeliveryNote.find(@dn.id).pending_delivery_intervention
      end
      
      should "NOT be able to be realized" do
        assert !@dn.can_be_realized?
      end
      
      should "NOT be realized successfully" do
        #TODO
      end
      
      should "NOT be able to be signed" do
        assert !@dn.can_be_signed?
      end
      
      #should "NOT be signed successfully" do
      #end
      
      context "(with a pending_delivery_intervention)" do
        setup do
          @intervention = create_scheduled_delivery_intervention_for(@dn)
          @dn.reload
          
          flunk "@intervention should be saved" if @intervention.new_record?
          flunk "@dn should have a pending_delivery_intervention" unless @dn.pending_delivery_intervention
        end
      
        teardown do
          @intervention = nil
        end
        
        should "be able to be scheduled" do
          assert @dn.can_be_scheduled?
        end
        
        should "edit pending_delivery_intervention successfully" do
          #TODO
        end
        
        should "NOT create another delivery_intervention" do
          #TODO
        end
        
        should "be able to be realized" do
          assert @dn.can_be_realized?
        end
        
        should "be realized successfully" do
          #TODO
        end
      end
      
      context "(with a delivered_delivery_intervention)" do
        setup do
          @intervention = create_delivered_delivery_intervention_for(@dn)
          @dn.reload
          
          flunk "@intervention should be saved" if @intervention.new_record?
          flunk "@dn should have a delivered_delivery_intervention" unless @dn.delivered_delivery_intervention
        end
      
        teardown do
          @intervention = nil
        end
        
        should "NOT be able to be scheduled" do
          assert !@dn.can_be_scheduled?
        end
        
        should "NOT edit delivered_delivery_intervention successfully" do
          #TODO
        end
        
        should "NOT create another delivery_intervention" do
          #TODO
        end
        
        should "NOT be able to be realized" do
          assert !@dn.can_be_realized?
        end
        
        should "NOT be realized successfully" do
          #TODO
        end
        
        should "be able to be signed" do
          assert @dn.can_be_signed?
        end
        
        should "be signed successfully" do
          #TODO
        end
      end
    end
    
    
    context "a CANCELLED delivery note" do
      setup do
        @dn = create_valid_delivery_note_for(@order)
        confirm_delivery_note(@dn)
        cancel_delivery_note(@dn)
        
        @dn.valid?
        flunk "@dn should be cancelled" unless @dn.was_cancelled?
      end
      
      teardown do
        @dn = nil
      end
      
      should "have a good 'status' value" do
        assert_equal DeliveryNote::STATUS_CANCELLED, @dn.status
      end
      
      should "NOT be able to be edited " do
        assert !@dn.can_be_edited?
      end
      
      should "NOT be updated successfully" do
        assert_creator_id_cannot_be_updated
        assert_ship_to_address_cannot_be_updated
        assert_delivery_note_contact_cannot_be_updated
        assert_delivery_note_items_cannot_be_updated
      end
      
      should "NOT be able to be destroyed" do
        assert !@dn.can_be_destroyed?
      end
      
      should "NOT be deleted successfully" do
        assert !@dn.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@dn.can_be_confirmed?
      end
      
      should "NOT be confirmed successfully" do
        assert !@dn.confirm
      end
      
      should "NOT be able to be cancelled" do
        assert !@dn.can_be_cancelled?
      end
      
      should "NOT be cancelled successfully" do
        assert !@dn.cancel
      end
      
      should "NOT be able to be scheduled" do
        assert !@dn.can_be_scheduled?
      end
      
      should "NOT be scheduled successfully" do
        #TODO
      end
      
      should "NOT be able to be realized" do
        assert !@dn.can_be_realized?
      end
      
      should "NOT be realized successfully" do
        #TODO
      end
      
      should "NOT be able to be signed" do
        assert !@dn.can_be_signed?
      end
      
      #should "NOT be signed successfully" do
      #end
    end
    
    
    context "a SIGNED delivery note" do
      setup do
        @dn = create_valid_delivery_note_for(@order)
        confirm_delivery_note(@dn)
        sign_delivery_note(@dn)
        
        @dn.valid?
        flunk "@dn should be signed" unless @dn.was_signed?
      end
      
      teardown do
        @dn = nil
      end
      
      should "have a good 'status' value" do
        assert_equal DeliveryNote::STATUS_SIGNED, @dn.status
      end
      
      should "NOT be able to be edited " do
        assert !@dn.can_be_edited?
      end
      
      should "NOT be updated successfully" do
        assert_creator_id_cannot_be_updated
        assert_ship_to_address_cannot_be_updated
        assert_delivery_note_contact_cannot_be_updated
        assert_delivery_note_items_cannot_be_updated
      end
      
      should "NOT be able to be destroyed" do
        assert !@dn.can_be_destroyed?
      end
      
      should "NOT be deleted successfully" do
        assert !@dn.destroy
      end
      
      should "NOT be able to be confirmed" do
        assert !@dn.can_be_confirmed?
      end
      
      should "NOT be confirmed successfully" do
        assert !@dn.confirm
      end
      
      should "NOT be able to be cancelled" do
        assert !@dn.can_be_cancelled?
      end
      
      should "NOT be cancelled successfully" do
        assert !@dn.cancel
      end
      
      should "NOT be able to be scheduled" do
        assert !@dn.can_be_scheduled?
      end
      
      should "NOT be scheduled successfully" do
        #TODO
      end
      
      should "NOT be able to be realized" do
        assert !@dn.can_be_realized?
      end
      
      should "NOT be realize successfully" do
        #TODO
      end
      
      should "NOT be able to be signed" do
        assert !@dn.can_be_signed?
      end
      
      #should "NOT be signed successfully" do
      #end
    end
    
  end
  
  context "Thanks to 'has_reference', a delivery_note" do
    setup do
      @reference_owner       = create_default_delivery_note
      @other_reference_owner = create_default_delivery_note
    end
    
    include HasReferenceTest
  end
  
  context "Thanks to has_contact, a delivery_note" do
    setup do
      @contact_owner = create_default_delivery_note
      @contact_keys = [ :delivery_note_contact ]
    end
    
    subject { @contact_owner }
          
    should_belong_to :delivery_note_contact
    
    include HasContactTest
  end
  
  private
    def confirm_delivery_note(delivery_note)
      delivery_note.confirm
      flunk "delivery_note should be confirmed" unless delivery_note.was_confirmed?
    end
    
    def cancel_delivery_note(delivery_note)
      delivery_note.cancel
      flunk "delivery_note should be cancelled" unless delivery_note.was_cancelled?
    end
    
    def sign_delivery_note(delivery_note)
      create_delivered_delivery_intervention_for(delivery_note)
      delivery_note.signed_on = Date.today
      delivery_note.attachment = @attachment
      delivery_note.sign
      flunk "delivery_note should be signed" unless delivery_note.was_signed?
    end
    
    def assert_creator_id_cannot_be_updated
      @dn.creator_id += 1
      @dn.valid?
      assert @dn.errors.invalid?(:creator_id), "creator_id should NOT be valid because it's NOT allowed to be updated"
    end
    
    def assert_ship_to_address_can_be_updated
      update_ship_to_address
      assert !@dn.errors.invalid?(:ship_to_address), "ship_to_address should be valid"
    end
    
    def assert_ship_to_address_cannot_be_updated
      update_ship_to_address
      assert @dn.errors.invalid?(:ship_to_address), "ship_to_address should NOT be valid because it's NOT allowed to be updated"
    end
    
    def update_ship_to_address
      @dn.ship_to_address.street_name = "new street name"
      @dn.valid?
    end
    
    def assert_delivery_note_contact_can_be_updated
      update_delivery_note_contact
      assert !@dn.errors.invalid?(:delivery_note_contact_id), "delivery_note_contact_id should be valid"
    end
    
    def assert_delivery_note_contact_cannot_be_updated
      update_delivery_note_contact
      assert @dn.errors.invalid?(:delivery_note_contact_id), "delivery_note_contact_id should NOT be valid because it's not allowed to be updated"
    end
    
    def update_delivery_note_contact
      old_contact = @dn.delivery_note_contact
      new_contact = (Contact.all - [ old_contact ]).first
      flunk "new_contact should exist and be different than old_contact" unless new_contact and new_contact != old_contact
      @dn.delivery_note_contact = new_contact
      @dn.valid?
    end
    
    def assert_delivery_note_items_can_be_updated
      update_delivery_note_items_by_editing_item
      assert !@dn.errors.invalid?(:delivery_note_items), "delivery_note_items should be valid"
      
      update_delivery_note_items_by_adding_item
      assert !@dn.errors.invalid?(:delivery_note_items), "delivery_note_items should be valid"
      
      update_delivery_note_items_by_removing_item
      assert !@dn.errors.invalid?(:delivery_note_items), "delivery_note_items should be valid"
    end
    
    def assert_delivery_note_items_cannot_be_updated
      update_delivery_note_items_by_editing_item
      assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because it's NOT allowed to be updated"
      
      update_delivery_note_items_by_adding_item
      assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because it's NOT allowed to be updated"
      
      update_delivery_note_items_by_removing_item
      assert @dn.errors.invalid?(:delivery_note_items), "delivery_note_items should NOT be valid because it's NOT allowed to be updated"
    end
    
    def update_delivery_note_items_by_editing_item
      @dn.delivery_note_items.reload
      
      @dn.delivery_note_items.first.quantity = 0
      @dn.valid?
    end
    
    def update_delivery_note_items_by_adding_item
      @dn.delivery_note_items.reload
      
      ref = @signed_quote.quote_items.last
      @dn.delivery_note_items.build(:quote_item_id => ref.id,
                                                         :quantity => ref.quantity)
      @dn.valid?
    end
    
    def update_delivery_note_items_by_removing_item
      @dn.delivery_note_items.reload

      @dn.delivery_note_items.pop
      @dn.valid?
    end
end
