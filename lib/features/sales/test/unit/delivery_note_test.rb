require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'
 
class DevlieryNoteTest < ActiveSupport::TestCase
  
  def setup
    @order = create_default_order
    @signed_quote = create_signed_quote_for(@order)
    
    @dn = DeliveryNote.new # the object must be clear to perform the test, so don't add any attributes on that object
    @dn.valid?
    
    @invalid_address = Address.new # assuming Address.new returns an invalid record by default
    @valid_address = Address.new(:street_name       => "Street Name",
                                 :country_name      => "Country",
                                 :city_name         => "City",
                                 :zip_code          => "01234",
                                 :has_address_type  => "DeliveryNote",
                                 :has_address_key   => "ship_to_address")
    
    @invalid_contact = Contact.new # assuming Contact.new returns an invalid record by default
    @valid_contact = Contact.new(:first_name => "First Name",
                                 :last_name => "Last Name",
                                 :contact_type_id => ContactType.create(:name => "Contact Type Name", :owner => "DeliveryNote").id,
                                 :email => "firstname@lastname.com",
                                 :job => "Job",
                                 :gender => "M")
    
    @attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "delivery_note_attachment.pdf"))
    
    flunk "@valid_address should be valid to perform the following tests"       unless @valid_address.valid?
    flunk "@invalid_address should NOT be valid to perform the following tests" if @invalid_address.valid?
    flunk "@valid_contact should be valid to perform the following tests"       unless @valid_contact.valid?
    flunk "@invalid_contact should NOT be valid to perform the following tests" if @invalid_contact.valid?
  end
  
  def teardown
    @order = @signed_quote = @dn = @attachment = nil
    @invalid_address = @valid_address = nil
    @invalid_contact = @valid_contact = nil
  end
  
  def test_presence_of_delivery_step
    assert @dn.errors.invalid?(:delivery_step_id), "delivery_step_id should NOT be valid because it's nil"
    
    @dn.delivery_step_id = 0
    @dn.valid?
    assert !@dn.errors.invalid?(:delivery_step_id), "delivery_step_id should be valid"
    assert @dn.errors.invalid?(:delivery_step), "delivery_step should NOT be valid because delivery_step_id is wrong"
    
    @dn.delivery_step_id = @order.pre_invoicing_step.delivery_step.id
    @dn.valid?
    assert !@dn.errors.invalid?(:delivery_step_id), "delivery_step_id should be valid"
    assert !@dn.errors.invalid?(:delivery_step), "delivery_step should be valid"
    
    @dn.delivery_step = @order.pre_invoicing_step.delivery_step
    @dn.valid?
    assert !@dn.errors.invalid?(:delivery_step_id), "delivery_step_id should be valid"
    assert !@dn.errors.invalid?(:delivery_step), "delivery_step should be valid"
  end
  
  def test_presence_of_creator
    assert @dn.errors.invalid?(:creator_id), "creator_id should NOT be a valid because it's nil"
    
    @dn.creator_id = 0
    @dn.valid?
    assert !@dn.errors.invalid?(:creator_id), "creator_id should be valid"
    assert @dn.errors.invalid?(:creator), "creator should NOT be valid because creator_id is wrong"
    
    @dn.creator_id = users(:powerful_user).id
    @dn.valid?
    assert !@dn.errors.invalid?(:creator_id), "creator_id should be valid"
    assert !@dn.errors.invalid?(:creator), "creator should be valid"
    
    @dn.creator = users(:powerful_user)
    @dn.valid?
    assert !@dn.errors.invalid?(:creator_id), "creator_id should be valid"
    assert !@dn.errors.invalid?(:creator), "creator should be valid"
  end
  
  def test_presence_of_ship_to_address
    assert @dn.errors.invalid?(:ship_to_address), "ship_to_address should NOT be a valid because it's nil"
    
    @dn.ship_to_address = @invalid_address
    @dn.valid?
    assert @dn.errors.invalid?(:ship_to_address), "ship_to_address should NOT be valid"
    
    @dn.ship_to_address = @valid_address
    @dn.valid?
    assert !@dn.errors.invalid?(:ship_to_address), "ship_to_address should be valid"
  end
  
  def test_presence_of_contacts
    @dn.delivery_step = @order.pre_invoicing_step.delivery_step #
    @order.contacts = [ @valid_contact ]                        # prepare delivery note to accept @valid_contact
    @order.save                                                 #
    
    assert @dn.errors.invalid?(:contact_ids), "contact_ids should NOT be valid because it's empty"
    
    # when contact is invalid
    @dn.contacts << @invalid_contact
    @dn.valid?
    assert !@dn.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert @dn.errors.invalid?(:contacts), "contacts should NOT be valid because it contains an invalid contact"
    
    # when contact_id is wrong
    @dn.contacts = []
    @dn.contact_ids [0]
    @dn.valid?
    assert @dn.errors.invalid?(:contact_ids), "contact_ids should NOT be valid because it contains a wrong contact ID"
    
    # when contact is NOT is the accepted list
    @dn.contacts = [ contacts(:pierre_paul_jacques) ]
    @dn.valid?
    assert !@dn.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert @dn.errors.invalid?(:contacts), "contact should NOT be valid because the contact is not present in the accepted list of contacts"
    
    # when contact is in the accepted list
    @dn.contacts = [ @valid_contact ]
    @dn.valid?
    assert !@dn.errors.invalid?(:contact_ids), "contact_ids should be valid"
    assert !@dn.errors.invalid?(:contacts), "contacts should be valid"
    
    # when length of contacts is too long
    @order.contacts << contacts(:pierre_paul_jacques)
    @order.save
    @dn.contacts = [ @valid_contact, contacts(:pierre_paul_jacques) ]
    @dn.valid?
    assert @dn.errors.invalid?(:contact_ids), "contact_ids should NOT be valid because it contains more than 1 contact"
  end
  
  def test_presence_of_associated_quote
    @dn.delivery_step = @order.pre_invoicing_step.delivery_step
    
    assert_not_nil @dn.associated_quote, "delivery_note should have an associated_quote"
    assert @dn.associated_quote.instance_of?(Quote), "associated_quote should be an instance of Quote"
  end
  
  def test_delivery_notes_quotes_product_references
    @dn.delivery_step = @order.pre_invoicing_step.delivery_step
    
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because it's empty"
    
    # when a quotes_product_reference_id is wrong
    @dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => 0)
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quotes_product_reference_id is wrong"
    assert !@dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quotes_product_reference_id), "quotes_product_reference_id should be valid"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quotes_product_reference), "quotes_product_reference should NOT be valid because quotes_product_reference_id is wrong"
    
    # when a quotes_product_reference is invalid
    @dn.delivery_notes_quotes_product_references = []
    @dn.delivery_notes_quotes_product_references.build.quotes_product_reference = QuotesProductReference.new # assuming QuotesProductReference.new returns an invalid record
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quotes_product_reference is invalid"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quotes_product_reference_id), "quotes_product_reference_id should NOT be valid because it's an invalid record"
    
    # when a quantity is nil
    @dn.delivery_notes_quotes_product_references = []
    @dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => @dn.associated_quote.quotes_product_references.first.id)
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quantity is nil"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's nil"
    
    # when a quantity is not in range
    @dn.delivery_notes_quotes_product_references.first.quantity = @dn.associated_quote.quotes_product_references.first.quantity + 1
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quantity is out of range (too big)"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's out of range (too big)"
    
    @dn.delivery_notes_quotes_product_references.first.quantity = -1
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quantity is out of range (too small)"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's out of range (too small)"
    
    # when a quantity is not a number
    @dn.delivery_notes_quotes_product_references.first.quantity = "not a number"
    @dn.valid?
    assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because quantity is not a number"
    assert @dn.delivery_notes_quotes_product_references.first.errors.invalid?(:quantity), "quantity should NOT be valid because it's not a number"
    
    # when all is ok
    @dn.delivery_notes_quotes_product_references = []
    @dn.associated_quote.quotes_product_references.each do |ref|
      @dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => ref.id,
                                                         :quantity => ref.quantity)
    end
    assert_equal @dn.associated_quote.quotes_product_references.size,
                 @dn.delivery_notes_quotes_product_references.size, "delivery_notes_quotes_product_references should be at the good size"
    @dn.valid?
    assert !@dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should be valid"
  end
  
  def test_status_when_nil
    @dn = create_valid_delivery_note_for(@order)
    
    assert_nil @dn.status, "@dn.status should be nil"
    assert @dn.uncomplete?, "delivery_note should be uncomplete"
    @dn.valid?
    assert !@dn.errors.invalid?(:status), "status should be valid"
  end
  
  def test_status_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert @dn.validated?, "delivery_note should be validated"
    assert_equal DeliveryNote::STATUS_VALIDATED, @dn.status, "status should be equal to #{DeliveryNote::STATUS_VALIDATED}"
    @dn.valid?
    assert !@dn.errors.invalid?(:status), "status should be valid"
  end
  
  def test_status_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert @dn.invalidated?, "delivery_note should be invalidated"
    assert_equal DeliveryNote::STATUS_INVALIDATED, @dn.status, "status should be equal to #{DeliveryNote::STATUS_INVALIDATED}"
    @dn.valid?
    assert !@dn.errors.invalid?(:status), "status should be valid"
  end
  
  def test_status_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert @dn.signed?, "delivery_note should be signed"
    assert_equal DeliveryNote::STATUS_SIGNED, @dn.status, "status should be equal to #{DeliveryNote::STATUS_SIGNED}"
    @dn.valid?
    assert !@dn.errors.invalid?(:status), "status should be valid"
  end
  
  def test_status_with_invalid_value
    @dn = create_valid_delivery_note_for(@order)
    
    @dn.status = "invalid value"
    @dn.valid?
    assert @dn.errors.invalid?(:status), "status should NOT be valid because it's not in the list"
  end
  
  def test_protected_attributes
    @dn = create_valid_delivery_note_for(@order)
    
    protected_attributes = { :status => DeliveryNote::STATUS_SIGNED,
                             :validated_on => Date.today + 3.days,
                             :invalidated_on => Date.today + 4.days,
                             :signed_on => Date.today + 5.days,
                             :public_number => 'RANDOM91291820' }
    
    protected_attributes.each do |k, v|
      flunk "protected_attributes.#{k} should NOT have the same value than @dn.#{k}. you should change the protected_attributes value to perform the following" if @dn[k].equal?(v)
    end
    
    @dn.update_attributes(protected_attributes)
    @dn.reload
    
    protected_attributes.each do |k,v|
      assert_not_equal @dn[k], v, "'#{k}' attribute should be protected from mass-assignment"
    end
  end
  
  def test_create_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    assert @dn.instance_of?(DeliveryNote), "@dn should be an instance of DeliveryNote"
    assert !@dn.new_record?, "@dn should NOT be a new record"
  end
  
  def test_validate_delivery_note_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.uncomplete?, "delivery_note should be uncomplete"
    assert @dn.validate_delivery_note, "@dn.validate_delivery_note should success"
  end
  
  def test_validate_delivery_note_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)

    assert @dn.validated?, "delivery_note should be validated"
    assert !@dn.validate_delivery_note, "@dn.validate_delivery_note should failed because it's already validated"
  end
  
  def test_validate_delivery_note_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert @dn.invalidated?, "delivery_note should be invalidated"
    assert !@dn.validate_delivery_note, "@dn.validate_delivery_note should failed because it's already invalidated"
  end
  
  def test_validate_delivery_note_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert @dn.signed?, "delivery_note should be signed"
    assert !@dn.validate_delivery_note, "@dn.validate_delivery_note should failed because it's already signed"
  end
  
  def test_invalidate_delivery_note_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.uncomplete?, "delivery_note should be uncomplete"
    assert !@dn.invalidate_delivery_note, "@dn.invalidate_delivery_note should failed because it's not validated"
  end
  
  def test_invalidate_delivery_note_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert @dn.validated?, "delivery_note should be validated"
    assert @dn.invalidate_delivery_note, "@dn.invalidate_delivery_note should success"
  end
  
  def test_invalidate_delivery_note_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert @dn.invalidated?, "delivery_note should be invalidated"
    assert !@dn.invalidate_delivery_note, "@dn.invalidate_delivery_note should failed because it's already invalidated"
  end
  
  def test_invalidate_delivery_note_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert @dn.signed?, "delivery_note should be signed"
    assert !@dn.invalidate_delivery_note, "@dn.invalidate_delivery_note should failed because it's already signed"
  end
  
  def test_sign_delivery_note_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.uncomplete?, "delivery_note should be uncomplete"
    
    prepare_new_intervention_for(@dn)
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note,
      "@dn.sign_delivery_note should failed because it's uncomplete"
  end
  
  def test_sign_delivery_note_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert @dn.validated?, "delivery_note should be validated"
    
    create_and_prepare_intervention_for_sign_delivery_note(@dn)
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert @dn.sign_delivery_note,
      "@dn.sign_delivery_note should success"
  end
  
  def test_sign_delivery_note_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    assert @dn.invalidated?, "delivery_note should be invalidated"
    
    prepare_new_intervention_for(@dn)
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note,
      "@dn.sign_delivery_note should failed because it's invalidated"
  end
  
  def test_sign_delivery_note_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    assert @dn.signed?, "delivery_note should be signed"
    
    prepare_new_intervention_for(@dn)
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note,
      "@dn.sign_delivery_note should failed because it's already signed"
  end
  
  def test_can_be_edited_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.can_be_edited?, "delivery_note should be editable"
  end
  
  def test_can_be_edited_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert !@dn.can_be_edited?, "delivery_note should NOT be editable because it's validated"
  end
  
  def test_can_be_edited_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert !@dn.can_be_edited?, "delivery_note should NOT be editable because it's invalidated"
  end
  
  def test_can_be_edited_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert !@dn.can_be_edited?, "delivery_note should NOT be editable because it's signed"
  end
  
  def test_can_be_deleted_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.can_be_deleted?, "delivery_note should be deletable"
  end
  
  def test_can_be_deleted_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert !@dn.can_be_deleted?, "delivery_note should NOT be deletable because it's validated"
  end
  
  def test_can_be_deleted_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert !@dn.can_be_deleted?, "delivery_note should NOT be deletable because it's invalidated"
  end
  
  def test_can_be_deleted_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert !@dn.can_be_deleted?, "delivery_note should NOT be deletable because it's signed"
  end
  
  def test_can_be_validated_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert @dn.can_be_validated?, "delivery_note should be validatable"
  end
  
  def test_can_be_validated_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert !@dn.can_be_validated?, "delivery_note should NOT be validatable because it's validated"
  end
  
  def test_can_be_validated_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert !@dn.can_be_validated?, "delivery_note should NOT be validatable because it's invalidated"
  end
  
  def test_can_be_validated_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert !@dn.can_be_validated?, "delivery_note should NOT be validatable because it's signed"
  end
  
  def test_can_be_invalidated_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert !@dn.can_be_invalidated?, "delivery_note should NOT be invalidatable because it's uncomplete"
  end
  
  def test_can_be_invalidated_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert @dn.can_be_invalidated?, "delivery_note should be invalidatable"
  end
  
  def test_can_be_invalidated_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert !@dn.can_be_invalidated?, "delivery_note should NOT be invalidatable because it's invalidated"
  end
  
  def test_can_be_invalidated_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert !@dn.can_be_invalidated?, "delivery_note should NOT be invalidatable because it's signed"
  end
  
  def test_can_be_signed_when_uncomplete
    @dn = create_valid_delivery_note_for(@order)
    
    assert !@dn.can_be_signed?, "delivery_note should NOT be signable because it's uncomplete"
  end
  
  def test_can_be_signed_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert @dn.can_be_signed?, "delivery_note should be signable"
  end
  
  def test_can_be_signed_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert !@dn.can_be_signed?, "delivery_note should NOT be signable because it's invalidated"
  end
  
  def test_can_be_signed_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert !@dn.can_be_signed?, "delivery_note should NOT be signable because it's signed"
  end
  
  def test_create_intervention_on_uncomplete_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    
    @intervention = @dn.interventions.build(:on_site => true, :scheduled_delivery_at => Time.now + 10.hours)
    @intervention.deliverers << Employee.first
    
    @dn.valid?
    assert @dn.errors.invalid?(:interventions), "delivery note should NOT be valid because it should NOT have intervention until its status is not validated > #{@dn.errors.full_messages.join(', ')}"
  end
  
  def test_create_intervention_on_invalidated_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    @intervention = @dn.interventions.build(:on_site => true, :scheduled_delivery_at => Time.now + 10.hours)
    @intervention.deliverers << Employee.first
    
    @dn.valid?
    assert @dn.errors.invalid?(:interventions), "delivery_note should NOT be valid because it should NOT have intervention until its status is not validated > #{@dn.errors.full_messages.join(', ')}"
  end
  
  def test_create_intervention_on_validated_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    flunk "delivery_note should NOT have a pending intervention to continue" if !@dn.pending_intervention.nil?
    flunk "delivery_note should be validated to continue" unless @dn.validate_delivery_note
    
    @intervention = @dn.interventions.build(:on_site => true, :scheduled_delivery_at => Time.now + 10.hours)
    @intervention.deliverers << Employee.first
    
    assert @dn.valid?, "delivery note should be valid > #{@dn.errors.full_messages.join(', ')}"
    @dn.save!
    
    assert_equal 1, @dn.interventions.size, "interventions.size should be equal to 1"
    assert_equal @intervention, @dn.interventions.first, "both variables should be the same instance"
  end
  
  def test_create_intervention_on_signed_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    flunk "delivery_note should have a pending intervention to continue" if @dn.pending_intervention.nil?
    
    @intervention.delivered = true
    @intervention.comments = "my comments"
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    flunk "delivery_note should be signed to continue" unless @dn.sign_delivery_note
    
    @second_intervention = @dn.interventions.build(:on_site => true, :scheduled_delivery_at => Time.now + 12.hours)
    @second_intervention.deliverers << Employee.first
    
    @dn.valid?
    assert @dn.errors.invalid?(:interventions), "interventions should NOT be valid because delivery_note is already signed"
  end
  
  def test_update_intervention_on_delivery_note
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    assert !@intervention.changed?, "intervention.changed? should return false"
    
    @intervention.delivered = false
    @intervention.comments = "my comment"
    assert @intervention.changed?, "intervention.changed? should return true"
    
    assert @dn.valid?, "delivery_note should be valid > #{@dn.errors.full_messages.join(', ')} > #{@dn.interventions.first.errors.full_messages.join(', ')}"
    @dn.save!
    
    assert !@intervention.changed?, "intervention.changed? should return false"
  end
  
  def test_pending_intervention_with_non_saved_record
    @dn = create_valid_delivery_note_for(@order)
    
    assert_nil @dn.pending_intervention, "delivery_note should NOT have a pending intervention"
    assert_equal 0, @dn.interventions.size, "delivery_note should have 0 intervention"
    
    @intervention = prepare_new_intervention_for(@dn)
    
    assert_equal 1, @dn.interventions.size, "delivery_note should have 1 intervention"
    assert_equal @intervention, @dn.interventions.first, "both variables should be the same instance"
    assert @dn.interventions.first.new_record?, "first intervention should be a new_record"
    assert_nil @dn.pending_intervention, "delivery_note should NOT have pending_intervention"
  end
  
  def test_pending_intervention_with_saved_record
    @dn = create_valid_delivery_note_for(@order)
    
    assert_nil @dn.pending_intervention, "delivery_note should NOT have a pending intervention"
    assert_equal 0, @dn.interventions.size, "delivery_note should have 0 intervention"
    
    @intervention = create_valid_intervention_for(@dn)
    
    assert_not_nil @dn.pending_intervention, "delivery_note should have a pending intervention"
    assert @dn.pending_intervention.instance_of?(Intervention), "pending_intervention should be an instance of Intervention"
    assert_equal @intervention, @dn.pending_intervention, "both variables should be the same instance"
    assert !@dn.pending_intervention.new_record?, "pending_intervention should NOT be a new_record"
  end
  
  def test_successful_intervention_with_non_saved_record
    @dn = create_valid_delivery_note_for(@order)
    
    assert_nil @dn.successful_intervention, "delivery_note should NOT have a successful intervention"
    assert_equal 0, @dn.interventions.size, "delivery_note should have 0 intervention"
    
    @intervention = prepare_new_intervention_for(@dn)
    @intervention.delivered = true
    
    assert_equal 1, @dn.interventions.size, "delivery_note should have 1 intervention"
    assert_equal @intervention, @dn.interventions.first, "both variables should be the same instance"
    assert @dn.interventions.first.new_record?, "first intervention should be a new_record"
    assert_nil @dn.successful_intervention, "delivery_note should NOT have successful_intervention"
  end
  
  def test_successful_intervention_with_saved_record
    @dn = create_valid_delivery_note_for(@order)
    
    assert_nil @dn.successful_intervention, "delivery_note should NOT have a successful intervention"
    assert_equal 0, @dn.interventions.size, "delivery_note should have 0 intervention"
    
    sign_delivery_note(@dn)
    
    assert_not_nil @dn.successful_intervention, "delivery_note should have a successful intervention"
    assert @dn.successful_intervention.instance_of?(Intervention), "successful_intervention should be an instance of Intervention"
    assert !@dn.successful_intervention.new_record?, "successful_intervention should NOT be a new_record"
  end
  
  def test_sign_delivery_note_without_intervention
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note, "sign_delivery_note should NOT success because a successful_intervention missing"
    assert @dn.errors.invalid?(:successful_intervention), "successful_intervention should NOT be valid because it's nil"
    #TODO
  end
  
  def test_sign_delivery_note_with_one_pending_intervention_and_without_changes_on_intervention
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    flunk "delivery_note should have a pending intervention to continue" if @dn.pending_intervention.nil?
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note, "sign_delivery_note should NOT success because pending_intervention is not valid"
    assert @dn.errors.invalid?(:interventions), "interventions should NOT be valid because pending_intervention is not valid"
    assert @intervention.errors.invalid?(:delivered), "delivered should NOT be valid because it's nil"
  end
  
  def test_sign_delivery_note_with_one_pending_intervention_and_with_undelivered_intervention
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    flunk "delivery_note should have a pending intervention to continue" if @dn.pending_intervention.nil?
    
    @intervention.delivered = false
    @intervention.comments = "my comments"
    assert @intervention.changed?, "@intervention.changed? should return true" 
    
    assert @dn.valid?, "delivery_note should be valid"
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert !@dn.sign_delivery_note, "sign_delivery_note should NOT success because pending_intervention should be delivered to sign delivery_note"
    
    assert @intervention.changed?, "@intervention.changed? should return true because it should NOT have been saved"
  end
  
  def test_sign_delivery_note_with_one_pending_intervention_and_with_delivered_intervention
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    flunk "delivery_note should have a pending intervention to continue" if @dn.pending_intervention.nil?
    
    @intervention.delivered = true
    @intervention.comments = "my comments"
    assert @intervention.changed?, "@intervention.changed? should return true"
    
    assert @dn.valid?, "delivery_note should be valid"
    
    @dn.signed_on = Date.today
    @dn.attachment = @attachment
    assert @dn.sign_delivery_note, "sign_delivery_note should success"
    
    assert !@intervention.changed?, "@intervention.changed? should return false because it should have been saved"
  end 
  
  def test_update_delivery_note_when_not_validated
    @dn = create_valid_delivery_note_for(@order)
    
    assert_creator_id_cannot_be_updated
    
    assert_ship_to_address_can_be_updated
    
    assert_contact_can_be_updated
    
    assert_delivery_notes_quotes_product_references_can_be_updated
  end
  
  def test_update_delivery_note_when_validated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    
    assert_creator_id_cannot_be_updated
    
    assert_ship_to_address_cannot_be_updated
    
    assert_contact_cannot_be_updated
    
    assert_delivery_notes_quotes_product_references_cannot_be_updated
  end
  
  def test_update_delivery_note_when_invalidated
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    invalidate_delivery_note(@dn)
    
    assert_creator_id_cannot_be_updated
    
    assert_ship_to_address_cannot_be_updated
    
    assert_contact_cannot_be_updated
    
    assert_delivery_notes_quotes_product_references_cannot_be_updated
  end
  
  def test_update_delivery_note_when_signed
    @dn = create_valid_delivery_note_for(@order)
    validate_delivery_note(@dn)
    sign_delivery_note(@dn)
    
    assert_creator_id_cannot_be_updated
    
    assert_ship_to_address_cannot_be_updated
    
    assert_contact_cannot_be_updated
    
    assert_delivery_notes_quotes_product_references_cannot_be_updated
  end
  
  def test_update_delivery_note_with_one_pending_intervention
    #TODO
  end
  
  def test_update_delivery_note_with_one_successful_intervention
    #TODO
  end
  
  def test_create_second_intervention_before_close_first
    @dn = create_valid_delivery_note_for(@order)
    create_valid_intervention_for(@dn)
    
    flunk "delivery_note should have a pending intervention to continue" if @dn.pending_intervention.nil?
    
    @second_intervention = @dn.interventions.build(:on_site => true,
                                                   :scheduled_delivery_at => Time.now + 10.hours)
    @second_intervention.deliverers << Employee.first
    @dn.valid?
    assert @dn.errors.invalid?(:interventions), "interventions should NOT be valid because delivery_note has one pending_intervention"
  end
  
  def test_create_second_intervention_after_disabling_first #delivered = false
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    @intervention.delivered = false
    @intervention.comments = "some comments"
    @dn.save!
    
    flunk "delivery_note should NOT have a pending intervention to continue" if !@dn.pending_intervention.nil?
    
    @second_intervention = @dn.interventions.build(:on_site => true,
                                                   :scheduled_delivery_at => Time.now + 10.hours)
    @second_intervention.deliverers << Employee.first
    @dn.valid?
    assert !@dn.errors.invalid?(:interventions), "interventions should be valid > #{@dn.errors.full_messages.join(', ')}"
  end
  
  def test_create_second_intervention_after_enabling_first #delivered = true
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    @intervention.delivered = true
    @dn.save!
    
    flunk "delivery_note should have a successful intervention to continue" if @dn.successful_intervention.nil?
    
    @second_intervention = @dn.interventions.build(:on_site => true,
                                                   :scheduled_delivery_at => Time.now + 10.hours)
    @second_intervention.deliverers << Employee.first
    @dn.valid?
    assert @dn.errors.invalid?(:interventions), "interventions should NOT be valid because delivery_note has one successful_intervention"
  end
  
  def test_disabling_intervention
    @dn = create_valid_delivery_note_for(@order)
    @intervention = create_valid_intervention_for(@dn)
    
    assert_not_nil @dn.pending_intervention, "delivery_note should have a pending_intervention"
    
    @intervention.delivered = false
    @intervention.comments = "my comment"
    
    assert @dn.valid?, "delivery_note should be valid"
    
    @dn.save!
    assert_nil @dn.pending_intervention, "delivery_note should NOT have a pending_intervention"
    assert_nil @dn.successful_intervention, "delivery_note should NOT have a successful_intervention"
  end
  
  def test_discards
    #TODO
  end
  
  private
    def validate_delivery_note(delivery_note)
      flunk "delivery_note should be validated to continue" unless delivery_note.validate_delivery_note
    end
    
    def invalidate_delivery_note(delivery_note)
      flunk "delivery_note should be invalidated to continue" unless delivery_note.invalidate_delivery_note
    end
    
    def create_and_prepare_intervention_for_sign_delivery_note(delivery_note)
      intervention = create_valid_intervention_for(delivery_note)
      intervention.delivered = true
      intervention.comments = "my comments"
      return intervention
    end
    
    def prepare_new_intervention_for(delivery_note)
      intervention = delivery_note.interventions.build(:on_site => true, :scheduled_delivery_at => Time.now + 10.hours)
      intervention.deliverers << Employee.first
      intervention.delivered = true
      intervention.comments = "my comments"
      return intervention
    end
    
    def sign_delivery_note(delivery_note)
      create_and_prepare_intervention_for_sign_delivery_note(delivery_note)
      delivery_note.signed_on = Date.today + 6.days
      delivery_note.attachment = @attachment
      flunk "delivery_note should be signed to continue" unless delivery_note.sign_delivery_note
    end
    
    def assert_creator_id_cannot_be_updated
      @dn.creator = users(:admin_user)
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
    
    def assert_contact_can_be_updated
      update_contact_by_editing_item
      assert !@dn.errors.invalid?(:contacts), "contacts should be valid"
      
      #TODO update_contact_by_replacing_item
    end
    
    def assert_contact_cannot_be_updated
      update_contact_by_editing_item
      assert @dn.errors.invalid?(:contacts), "contacts should NOT be valid because it's not allowed to be updated"
      
      #TODO update_contact_by_replacing_item
    end
    
    def update_contact_by_editing_item
      @dn.contact.first_name = "new first name"
      @dn.valid?
    end
    
    def update_contact_by_replacing_item
      #TODO
    end
    
    def assert_delivery_notes_quotes_product_references_can_be_updated
      update_delivery_notes_quotes_product_references_by_editing_item
      assert !@dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should be valid"
      
      update_delivery_notes_quotes_product_references_by_adding_item
      assert !@dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should be valid"
      
      update_delivery_notes_quotes_product_references_by_removing_item
      assert !@dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should be valid"
    end
    
    def assert_delivery_notes_quotes_product_references_cannot_be_updated
      update_delivery_notes_quotes_product_references_by_editing_item
      assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because it's NOT allowed to be updated"
      
      update_delivery_notes_quotes_product_references_by_adding_item
      assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because it's NOT allowed to be updated"
      
      update_delivery_notes_quotes_product_references_by_removing_item
      assert @dn.errors.invalid?(:delivery_notes_quotes_product_references), "delivery_notes_quotes_product_references should NOT be valid because it's NOT allowed to be updated"
    end
    
    def update_delivery_notes_quotes_product_references_by_editing_item
      @dn.delivery_notes_quotes_product_references.reload
      
      @dn.delivery_notes_quotes_product_references.first.quantity = 0
      @dn.valid?
    end
    
    def update_delivery_notes_quotes_product_references_by_adding_item
      @dn.delivery_notes_quotes_product_references.reload
      
      ref = @signed_quote.quotes_product_references.last
      @dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => ref.id,
                                                         :quantity => ref.quantity)
      @dn.valid?
    end
    
    def update_delivery_notes_quotes_product_references_by_removing_item
      @dn.delivery_notes_quotes_product_references.reload

      @dn.delivery_notes_quotes_product_references.pop
      @dn.valid?
    end
    
end
