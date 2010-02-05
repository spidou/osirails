require 'lib/features/thirds/test/thirds_test'
require File.dirname(__FILE__) + '/unit/product_base_test'

class Test::Unit::TestCase
  
  def prepare_sales_processes
    OrderType.all.each do |order_type|
      Step.all.each do |step|
        order_type.sales_processes.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
      end
    end
  end
  
  def create_default_order(factorised_customer = true)
    prepare_sales_processes
    
    ## prepare customer
    customer = create_default_customer(factorised_customer)
    
    ## prepare society_activity_sector
    society_activity_sector = SocietyActivitySector.first
    society_activity_sector.order_types << OrderType.all
    
    order = Order.new(:title => "Titre", :customer_needs => "Customer Needs", :previsional_delivery => Time.now + 10.days)
    order.commercial = employees(:john_doe)
    order.creator = users(:powerful_user)
    order.customer = customer
    order.contacts = [ customer.contacts.first, customer.contacts.last ]
    order.society_activity_sector = society_activity_sector
    order.order_type = society_activity_sector.order_types.first
    order.build_bill_to_address(order.customer.bill_to_address.attributes)
    order.build_ship_to_address(order.customer.establishments.first)
    order.approaching = approachings(:email)
    flunk "Order should be saved > #{order.errors.full_messages.join(', ')}" unless order.save
    return order
  end
  
  def create_valid_product_for(order)
    product = order.products.build
    product.product_reference_id  = product_references(:product_reference1).id
    product.name                  = product_references(:product_reference1).name
    product.description           = "My description"
    product.dimensions            = "1000x500"
    product.quantity              = 3
    product.save!
    return product
  end
  
  def create_quote_for(order)
    x = 4 # number of products and quote_items
    x.times do
      create_valid_product_for(order)
    end
    
    quote = order.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days')
    quote.creator = users(:powerful_user)
    quote.contacts << contacts(:pierre_paul_jacques)
    
    order.products.each do |product|
      quote.build_quote_item(:product_id  => product.id,
                             :order_id    => order.id,
                             :name        => "Product Name",
                             :description => "Product description",
                             :dimensions  => "1000x2000",
                             :quantity    => 2,
                             :unit_price  => 20000,
                             :prizegiving => 0.0,
                             :vat         => 19.6)
    end
    
    flunk "Quote should be created" unless quote.save
    flunk "Quote should have #{x} quote_items" unless quote.quote_items.count == x
    return quote
  end
  
  def create_signed_quote_for(order)
    quote = create_quote_for(order)
    flunk "Quote should be confirmed"           unless quote.confirm
    flunk "Quote should be sended to customer"  unless quote.send_to_customer(:sended_on            => Date.today,
                                                                              :send_quote_method_id => send_quote_methods(:mail).id)
    
    attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
    flunk "Quote should be signed" unless quote.sign(:signed_on          => Date.today,
                                                     :order_form_type_id => order_form_types(:signed_quote).id,
                                                     :order_form         => attachment)
    return quote
  end
  
  def create_valid_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    dn.associated_quote.quote_items.each do |ref|
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
    end
    dn.save!
    
    flunk "order should have all its products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_partial_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    count = 0
    dn.associated_quote.quote_items.each do |ref|
      break if count == 2
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
      count += 1
    end
    dn.save!
    
    flunk "order should NOT have all its products delivered or scheduled" if order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_complementary_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    dn = order.build_delivery_note_with_remaining_products_to_deliver
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    dn.save!
    
    flunk "order should have all its products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_intervention_for(delivery_note)
    flunk "delivery_note should NOT have interventions to continue > #{delivery_note.interventions.inspect}" unless delivery_note.interventions.empty?
    flunk "delivery_note should be validated to continue" if !delivery_note.validated? and !delivery_note.validate_delivery_note
    
    intervention = delivery_note.interventions.build(:on_site => true,
                                                     :scheduled_delivery_at => Time.now + 10.hours)
    intervention.deliverers << Employee.first
    
    intervention.save!
    return intervention
  end
  
  def create_valid_discard_for(delivery_note)
    intervention = create_valid_intervention_for(delivery_note)
    intervention.delivered = true
    intervention.comments = "my special comment"
    
    flunk "delivery_note should be valid to perform the following" unless delivery_note.valid?
    
    reference = delivery_note.delivery_note_items.first
    discard = reference.build_discard(:comments => "my special comment",
                                      :quantity => reference.quantity,
                                      :discard_type_id => discard_types(:low_quality).id)
    
    flunk "delivery_note should be saved > #{delivery_note.errors.full_messages.join(', ')}" unless delivery_note.save
    return discard
  end
  
  def sign_delivery_note(delivery_note)
    intervention = create_valid_intervention_for(delivery_note)
    intervention.delivered = true
    intervention.comments = "my comments"
    delivery_note.signed_on = Date.today + 6.days
    delivery_note.attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "delivery_note_attachment.pdf"))
    
    flunk "delivery_note should be signed to continue" unless delivery_note.sign_delivery_note
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
  
  def create_valid_deposit_invoice_for(order)
    signed_quote = create_signed_quote_for(order)
    
    invoice = order.invoices.build
    
    invoice.invoice_type    = invoice_types(:deposit_invoice)
    invoice.creator         = User.first
    invoice.contact         = order.contacts.first
    invoice.bill_to_address = order.bill_to_address
    invoice.published_on    = Date.today
    
    invoice.deposit         = 40
    invoice.deposit_amount  = invoice.associated_quote.net_to_paid * 0.4
    invoice.deposit_vat     = 19.6
    invoice.deposit_comment = "This is a deposit invoice."
    invoice.build_or_update_free_item_for_deposit_invoice
    
    invoice.due_dates.build(:date => Date.today, :net_to_paid => ( invoice.net_to_paid ))
    invoice.save!
    
    flunk "invoice should be saved to perform the following" if invoice.new_record?
    return invoice
  end
  
  def create_sended_deposit_invoice_for(order)
    invoice = create_valid_deposit_invoice_for(order)
    invoice.confirm
    
    invoice.send_to_customer(:sended_on => Date.today, :send_invoice_method_id => send_invoice_methods(:fax).id)
    
    flunk "invoice should be sended to perform the following > #{invoice.errors.inspect}" unless invoice.was_sended?
    return invoice
  end
    
  def create_default_mockup
    order = create_default_order
    mockup = order.mockups.build(:name => "Sample",
                                 :description => "Sample de maquette destiné aux tests unitaires",
                                 :graphic_unit_measure => graphic_unit_measures(:normal), 
                                 :creator => users(:admin_user),
                                 :mockup_type => mockup_types(:normal),
                                 :product => create_valid_product_for(order),
                                 :graphic_item_version_attributes => ( {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")),
                                                                        :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))} )
                                )

    flunk "mockup should be saved > #{mockup.errors.full_messages.join(', ')}" unless mockup.save
    return mockup
  end
  
  def create_default_graphic_document
    order = create_default_order
    gd = order.graphic_documents.build(:name => "Sample", 
                                       :description => "Sample de document graphique destiné aux tests unitaires", 
                                       :graphic_unit_measure => graphic_unit_measures(:normal), 
                                       :creator => users(:admin_user), 
                                       :graphic_document_type => graphic_document_types(:normal),
                                       :graphic_item_version_attributes => ( {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg")),
                                                                              :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))} )
                                      )    
                                      
    flunk "gd should be saved > #{gd.errors.full_messages.join(', ')}" unless gd.save
    return gd
  end
  
  def create_default_press_proof
    order      = create_default_order
    john_id    = employees(:john_doe).id
    admin_id   = users(:admin_user).id
    product_id = create_valid_product_for(order).id
    graphic_item_version = create_valid_mockup(order, product_id).current_version
    
    press_proof = PressProof.new( :order_id          => order.id,
                                  :product_id        => product_id,
                                  :creator_id        => admin_id,
                                  :internal_actor_id => john_id,
                                  :press_proof_item_attributes =>[ {:graphic_item_version_id => graphic_item_version.id} ])
    flunk "press proof should be saved > #{press_proof.errors.full_messages.join(', ')}" unless press_proof.save
    return press_proof
  end

  # OPTIMIZE to respect DRY
  # use here to give the possibility to create a valid mockup with the good order and a specified product
  #
  def create_valid_mockup(order, product_id)
    mockup = order.mockups.build(:name => "Sample",
                                 :description => "Sample de maquette destiné aux tests unitaires",
                                 :graphic_unit_measure => graphic_unit_measures(:normal), 
                                 :creator => users(:admin_user),
                                 :mockup_type => mockup_types(:normal),
                                 :product_id => product_id,
                                 :graphic_item_version_attributes => ( {:image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") )} )
                                )                             

    flunk "mockup should be saved > #{mockup.errors.full_messages.join(', ')}" unless mockup.save
    return mockup
  end
  
  def create_default_dunning
    press_proof = create_default_press_proof
    press_proof.confirm
    press_proof.send_to_customer({:sended_on => Date.today, :document_sending_method_id => document_sending_methods(:fax).id})
    
    dunning = press_proof.dunnings.build(:date       => Date.today,
                                         :comment    => "comment for tests",
                                         :creator_id => users(:admin_user).id,
                                         :dunning_sending_method_id => dunning_sending_methods(:telephone).id)

    flunk "dunning should be saved > #{dunning.errors.full_messages.join(', ')} #{dunning.inspect} #{dunning.date} #{Date.today}" unless dunning.save
    return dunning
  end
end
