require 'test/test_helper'

require 'lib/features/thirds/test/thirds_test'
require 'lib/features/logistics/test/logistics_test'
require File.dirname(__FILE__) + '/unit/product_base_test'
require File.dirname(__FILE__) + '/unit/product_test'
require File.dirname(__FILE__) + '/unit/product_reference_category_base_test'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
  
  def prepare_sales_processes
    OrderType.all.each do |order_type|
      Step.all.each do |step|
        order_type.sales_processes.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
      end
    end
  end
  
  ## ORDER METHODS
  def create_default_order(factorised_customer = true)
    prepare_sales_processes
    
    customer = get_customer(factorised_customer)
    
    ## prepare society_activity_sector
    society_activity_sector = SocietyActivitySector.first
    society_activity_sector.order_types << OrderType.all
    
    order = Order.new(:title => "Titre", :customer_needs => "Customer Needs", :previsional_delivery => Time.now + 10.days)
    order.commercial = employees(:john_doe)
    order.creator = users(:sales_user)
    order.customer = customer
    order.order_contact_id = customer.contacts.first.id
    order.society_activity_sector = society_activity_sector
    order.order_type = society_activity_sector.order_types.first
    order.build_bill_to_address(order.customer.bill_to_address.attributes)
    order.build_ship_to_address(order.customer.establishments.first)
    order.approaching = approachings(:email)
    order.save!
    return order
  end
  
  def create_default_product_reference
    return ProductReference.create!( :product_reference_sub_category_id => product_reference_categories(:child).id, :name => "Default Product Reference" )
  end
  
  def create_default_end_product(order = nil)
    product_reference = create_default_product_reference
    order ||= create_default_order
    
    return order.end_products.create!( :product_reference_id  => product_reference.id,
                                       :name                  => "Default End Product",
                                       :quantity              => 1,
                                       :prizegiving           => 0 )
  end
  
  ## QUOTE METHODS
  def create_quote_for(order)
    x = 4 # number of end_products and quote_items
    x.times do
      create_default_end_product(order)
    end
    
    quote = order.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days')
    quote.creator = users(:sales_user)
    quote.quote_contact_id = contacts(:pierre_paul_jacques).id
    
    order.end_products.each do |end_product|
      quote.build_quote_item(:end_product_id  => end_product.id,
                             :name            => "Product Name",
                             :description     => "Product description",
                             :dimensions      => "1000x2000",
                             :quantity        => 2,
                             :unit_price      => 20000,
                             :prizegiving     => 0.0,
                             :vat             => 19.6)
    end
    
    flunk "Quote should be created" unless quote.save
    flunk "Quote should have #{x} quote_items" unless quote.quote_items.count == x
    return quote
  end
  
  def create_default_quote
    order = create_default_order
    quote = create_quote_for(order)
    return quote
  end
  
  def create_signed_quote_for(order)
    quote = create_quote_for(order)
    flunk "Quote should be confirmed"           unless quote.confirm
    flunk "Quote should be sended to customer"  unless quote.send_to_customer(:sended_on            => Date.today,
                                                                              :send_quote_method_id => send_quote_methods(:mail).id)
    
    attachment = File.new(File.join(Test::Unit::TestCase.fixture_path, "order_form.pdf"))
    flunk "Quote should be signed" unless quote.sign(:signed_on          => Date.today,
                                                     :order_form_type_id => order_form_types(:signed_quote).id,
                                                     :order_form         => attachment)
    return quote
  end
  
  ## DELIVERY_NOTE METHODS
  def create_valid_delivery_note_for(order, delivery_note_type = nil)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator          = users(:sales_user)
    dn.ship_to_address  = address
    dn.delivery_note_contact_id = contacts(:pierre_paul_jacques).id
    dn.delivery_note_type = delivery_note_type || delivery_note_types(:delivery_and_installation)
    
    dn.associated_quote.quote_items.each do |ref|
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
    end
    dn.save!
    
    flunk "order should have all its end_products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_partial_delivery_note_for(order, delivery_note_type = nil)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator            = users(:sales_user)
    dn.ship_to_address    = address
    dn.delivery_note_contact_id = contacts(:pierre_paul_jacques).id
    dn.delivery_note_type = delivery_note_type || delivery_note_types(:delivery_and_installation)
    
    count = 0
    dn.associated_quote.quote_items.each do |ref|
      break if count == 2
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
      count += 1
    end
    dn.save!
    
    flunk "order should NOT have all its end_products delivered or scheduled" if order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_complementary_delivery_note_for(order, delivery_note_type = nil)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.build_delivery_note_with_remaining_end_products_to_deliver
    dn.creator          = users(:sales_user)
    dn.ship_to_address  = address
    dn.delivery_note_contact_id = contacts(:pierre_paul_jacques).id
    dn.delivery_note_type = delivery_note_type || delivery_note_types(:delivery_and_installation)
    
    dn.save!
    
    flunk "order should have all its end_products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def build_valid_delivery_intervention_for(delivery_note)
    intervention = delivery_note.delivery_interventions.build(:scheduled_delivery_at        => Time.now,
                                                              :scheduled_internal_actor_id  => Employee.first.id,
                                                              :scheduled_intervention_hours => 2)
    
    intervention.scheduled_delivery_subcontractor_id      = Subcontractor.first.id if delivery_note.delivery?
    intervention.scheduled_installation_subcontractor_id  = Subcontractor.first.id if delivery_note.installation?
    
    return intervention
  end
  
  #def create_valid_delivery_intervention_for(delivery_note)
  def create_scheduled_delivery_intervention_for(delivery_note)
    flunk "delivery_note should NOT have a pending_delivery_intervention" if delivery_note.pending_delivery_intervention
    
    delivery_note.confirm unless delivery_note.was_confirmed?
    flunk "delivery_note should be confirmed" unless delivery_note.was_confirmed?
    
    intervention = build_valid_delivery_intervention_for(delivery_note)
    
    intervention.save!
    return intervention
  end
  
  def create_delivered_delivery_intervention_for(delivery_note)
    create_scheduled_delivery_intervention_for(delivery_note)
    delivery_note = DeliveryNote.find(delivery_note.id)
    
    flunk "delivery_note should have a pending_delivery_intervention" unless delivery_note.pending_delivery_intervention
    
    intervention = delivery_note.pending_delivery_intervention
    intervention.attributes = { :delivered          => true,
                                :delivery_at        => intervention.scheduled_delivery_at,
                                :internal_actor_id  => intervention.scheduled_internal_actor_id,
                                :intervention_hours => intervention.scheduled_intervention_hours }
    intervention.delivery_subcontractor_id      = intervention.scheduled_delivery_subcontractor_id      if delivery_note.delivery?
    intervention.installation_subcontractor_id  = intervention.scheduled_installation_subcontractor_id  if delivery_note.installation?
    
    intervention.save!
    
    flunk "delivery_note should have a delivered_delivery_intervention" unless delivery_note.delivered_delivery_intervention
    
    return intervention
  end
  
#  def create_valid_discard_for(delivery_note)
#    intervention = create_valid_delivery_intervention_for(delivery_note)
#    intervention.delivered = true
#    intervention.comments = "my special comment"
#    
#    flunk "delivery_note should be valid" unless delivery_note.valid?
#    
#    reference = delivery_note.delivery_note_items.first
#    discard = reference.build_discard(:comments => "my special comment",
#                                      :quantity => reference.quantity,
#                                      :discard_type_id => discard_types(:low_quality).id)
#    
#    flunk "delivery_note should be saved > #{delivery_note.errors.full_messages.join(', ')}" unless delivery_note.save
#    return discard
#  end
  
  def sign_delivery_note(delivery_note)
    intervention = create_delivered_delivery_intervention_for(delivery_note)
    
    delivery_note.signed_on = Date.today
    delivery_note.attachment = File.new(File.join(Test::Unit::TestCase.fixture_path, "delivery_note_attachment.pdf"))
    delivery_note.sign
    
    flunk "delivery_note should be signed" unless delivery_note.was_signed?
    return delivery_note
  end
  
  def create_signed_delivery_note_for(order)
    delivery_note = create_valid_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
  
  def create_signed_partial_delivery_note_for(order)
    delivery_note = create_valid_partial_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
  
  def create_signed_complementary_delivery_note_for(order)
    delivery_note = create_valid_complementary_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
  
  def create_default_delivery_note
    order = create_default_order
    create_signed_quote_for(order)
    
    delivery_note = create_valid_delivery_note_for(order)
    return delivery_note
  end
  
  ## INVOICE METHODS
  def create_valid_deposit_invoice_for(order)
    signed_quote = create_signed_quote_for(order)
    
    invoice = order.invoices.build
    
    invoice.invoice_type    = invoice_types(:deposit_invoice)
    invoice.creator         = User.first
    invoice.invoice_contact_id = order.all_contacts.first.id
    invoice.bill_to_address = order.bill_to_address
    invoice.published_on    = Date.today
    
    invoice.deposit         = 40
    invoice.deposit_amount  = invoice.associated_quote.net_to_paid * 0.4
    invoice.deposit_vat     = 19.6
    invoice.deposit_comment = "This is a deposit invoice."
    invoice.build_or_update_free_item_for_deposit_invoice
    
    invoice.due_dates.build(:date => Date.today, :net_to_paid => ( invoice.net_to_paid ))
    invoice.save!
    
    flunk "invoice should be saved" if invoice.new_record?
    return invoice
  end
  
  def create_sended_deposit_invoice_for(order)
    invoice = create_valid_deposit_invoice_for(order)
    invoice.confirm
    
    invoice.send_to_customer(:sended_on => Date.today, :send_invoice_method_id => send_invoice_methods(:fax).id)
    
    flunk "invoice should be sended > #{invoice.errors.inspect}" unless invoice.was_sended?
    return invoice
  end
  
  def create_default_invoice
    order = create_default_order
    invoice = create_valid_deposit_invoice_for(order)
    return invoice
  end
  
  ## GRAPHIC_ITEM METHODS
  def create_default_mockup(order = nil, end_product = nil)
    order ||= create_default_order
    end_product ||= create_default_end_product(order)
    
    mockup = order.mockups.build(:name                  => "Sample",
                                 :description           => "Sample de maquette destiné aux tests unitaires",
                                 :graphic_unit_measure  => graphic_unit_measures(:normal), 
                                 :creator               => users(:sales_user),
                                 :mockup_type           => mockup_types(:normal),
                                 :end_product           => end_product,
                                 :graphic_item_version_attributes => ( {:image  => File.new( File.join(Test::Unit::TestCase.fixture_path, "graphic_item.jpg")),
                                                                        :source => File.new( File.join(Test::Unit::TestCase.fixture_path, "order_form.pdf"))} )
                                )
    mockup.save!
    flunk "mockup should be saved" if mockup.new_record?
    return mockup
  end
  
  def create_default_graphic_document
    order = create_default_order
    gd = order.graphic_documents.build(:name                  => "Sample", 
                                       :description           => "Sample de document graphique destiné aux tests unitaires", 
                                       :graphic_unit_measure  => graphic_unit_measures(:normal), 
                                       :creator               => users(:sales_user), 
                                       :graphic_document_type => graphic_document_types(:normal),
                                       :graphic_item_version_attributes => ( {:image  => File.new( File.join(Test::Unit::TestCase.fixture_path, "graphic_item.jpg")),
                                                                              :source => File.new( File.join(Test::Unit::TestCase.fixture_path, "order_form.pdf"))} )
                                      )    
                                      
    flunk "gd should be saved > #{gd.errors.full_messages.join(', ')}" unless gd.save
    return gd
  end
  
  def build_default_press_proof(order = nil, end_product = nil, creator = nil, internal_actor = nil)
    order          ||= create_default_order
    internal_actor ||= employees(:john_doe)
    creator        ||= users(:sales_user)
    end_product    ||= create_default_end_product(order)
    graphic_item_version = create_default_mockup(order, end_product).current_version
    
    press_proof = PressProof.new( :order_id          => order.id,
                                  :end_product_id    => end_product.id,
                                  :creator_id        => creator.id,
                                  :internal_actor_id => internal_actor.id,
                                  :press_proof_item_attributes =>[ {:graphic_item_version_id => graphic_item_version.id} ])
  end
  
  def create_default_press_proof(order = nil, end_product = nil, creator = nil, internal_actor = nil)
    press_proof = build_default_press_proof(order, end_product, creator, internal_actor)
    flunk "press proof should be saved > #{press_proof.errors.full_messages.join(', ')}" unless press_proof.save
    return press_proof
  end

  def get_confirmed_press_proof(press_proof = create_default_press_proof)
    press_proof.confirm
    press_proof
  end
  
  def get_sended_press_proof(press_proof = create_default_press_proof, date = Date.today)
    press_proof = get_confirmed_press_proof(press_proof) unless press_proof.can_be_sended?
    options     = {:sended_on => date, :document_sending_method_id => document_sending_methods(:courrier).id}
                   
    press_proof.send_to_customer(options)
    press_proof
  end
  
  def get_signed_press_proof(press_proof = create_default_press_proof, date = Date.today)
    press_proof = get_sended_press_proof(press_proof) unless press_proof.can_be_signed?
    options     = {:signed_on => date, :signed_press_proof => File.new(File.join(Test::Unit::TestCase.fixture_path, "signed_press_proof.pdf"))}
                   
    press_proof.sign(options)
    press_proof
  end
  
  def get_cancelled_press_proof(press_proof = create_default_press_proof)
    press_proof = get_confirmed_press_proof(press_proof) unless press_proof.can_be_cancelled?
    
    press_proof.cancel
    press_proof
  end
  
  def get_revoked_press_proof(press_proof = create_default_press_proof, actor = users(:sales_user), comment = "comment", date = Date.today)
    press_proof = get_signed_press_proof(press_proof) unless press_proof.can_be_revoked?
    options = {:revoked_by_id => actor.id, :revoked_on => date, :revoked_comment => comment}
                
    press_proof.revoke(options)
    press_proof
  end
  
  ## DUNNING METHODS
  def create_default_dunning
    press_proof = create_default_press_proof
    get_sended_press_proof(press_proof)
    
    dunning = press_proof.dunnings.build(:date       => Date.today,
                                         :comment    => "comment for tests",
                                         :creator_id => User.first.id,
                                         :dunning_sending_method_id => DunningSendingMethod.first.id)

    flunk "dunning should be saved > #{dunning.errors.full_messages.join(', ')}" unless dunning.save
    return dunning
  end
end
