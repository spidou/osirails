require 'lib/features/thirds/test/thirds_test'

class Test::Unit::TestCase
  
  def prepare_sales_processes
    OrderType.all.each do |order_type|
      Step.all.each do |step|
        order_type.sales_processes.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
      end
    end
  end
  
  def create_default_order
    prepare_sales_processes
    
    ## prepare customer
    customer = create_default_customer
    
    ## prepare society_activity_sector
    society_activity_sector = SocietyActivitySector.first
    society_activity_sector.order_types << OrderType.all
    
    order = Order.new(:title => "Titre", :customer_needs => "Customer Needs", :previsional_delivery => Time.now + 10.days)
    order.commercial = employees(:john_doe)
    order.creator = users(:powerful_user)
    order.customer = customer
    order.contacts << customer.contacts.first
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
    product.product_reference_id = product_references(:product_reference1).id
    product.name        = product_references(:product_reference1).name
    product.description = "My description"
    product.dimensions  = "1000x500"
    product.quantity    = 3
    product.save!
    return product
  end
  
  def create_signed_quote_for(order)
    quote = order.commercial_step.estimate_step.quotes.build(:validity_delay => 30,
                                                             :validity_delay_unit => 'days')
    quote.creator = users(:powerful_user)
    quote.contacts << contacts(:pierre_paul_jacques)
    quote.quotes_product_references.build(:name => 'first reference',
                                          :description => 'first reference description',
                                          :quantity => '20',
                                          :unit_price => '1430.00',
                                          :vat => '8.5',
                                          :product_reference_id => product_references(:product_reference1).id)
    quote.quotes_product_references.build(:name => 'second reference',
                                          :description => 'second reference description',
                                          :quantity => '30',
                                          :unit_price => '2540.00',
                                          :vat => '19.6',
                                          :product_reference_id => product_references(:product_reference2).id)
    quote.quotes_product_references.build(:name => 'third reference',
                                          :description => 'third reference description',
                                          :quantity => '10',
                                          :unit_price => '4000.00',
                                          :vat => '19.6',
                                          :product_reference_id => product_references(:product_reference3).id)
    
    flunk "Quote should be created"   unless quote.save
    flunk "Quote should be validated" unless quote.validate_quote
    flunk "Quote should be sended"    unless quote.send_quote(:sended_on => Date.today,
                                                              :send_quote_method_id => send_quote_methods(:mail).id)
    
    file = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
    flunk "Quote should be signed"    unless quote.sign_quote(:signed_on => Date.today,
                                                              :order_form_type_id => order_form_types(:signed_quote).id,
                                                              :order_form => file)
    return quote
  end
  
  def create_valid_delivery_note_for(order)
    # prepare order
    order.contacts = [ contacts(:pierre_paul_jacques) ]
    order.save!
    
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.pre_invoicing_step.delivery_step.delivery_notes.build
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    count = 0
    dn.associated_quote.quotes_product_references.each do |ref|
      break if count == 2
      dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => ref.id,
                                                        :quantity => ref.quantity)
      count += 1
    end
    
    dn.save!
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
    
    reference = delivery_note.delivery_notes_quotes_product_references.first
    discard = reference.build_discard(:comments => "my special comment",
                                      :quantity => reference.quantity,
                                      :discard_type_id => discard_types(:low_quality).id)
    
    flunk "delivery_note should be saved > #{delivery_note.errors.full_messages.join(', ')}" unless delivery_note.save
    return discard
  end
end
