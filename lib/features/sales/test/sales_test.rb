class Test::Unit::TestCase
  
  def create_default_order
    create_default_order_types
    
    customer = thirds(:first_customer)
    customer.contacts << contacts(:pierre_paul_jacques)
    customer.save!
    
    order = Order.new(:title => "Titre", :previsional_delivery => Time.now + 10.days)
    order.commercial = employees(:john_doe)
    order.creator = users(:powerful_user)
    order.customer = customer
    order.establishment = establishments(:first_establishment)
    order.contacts << customer.contacts.first
    order.order_type = OrderType.first
    
    flunk "Order should be created" unless order.save
    return order
  end
  
  def create_default_order_types
    OrderType.create(:title => "Normal")
    OrderType.create(:title => "SAV")
  end
  
  def create_signed_quote_for(order)
    quote = order.commercial_step.estimate_step.quotes.build(:validity_delay => 30,
                                                             :validity_delay_unit => 'days')
    quote.creator = users(:powerful_user)
    quote.contacts << contacts(:pierre_paul_jacques)
    quote.quotes_product_references.build(:name => 'name',
                                          :description => 'description',
                                          :quantity => '20',
                                          :unit_price => '1430.00',
                                          :vat => '8.5',
                                          :product_reference_id => product_references(:product_reference1).id)
    quote.quotes_product_references.build(:name => 'name',
                                          :description => 'description',
                                          :quantity => '30',
                                          :unit_price => '2540.00',
                                          :vat => '19.6',
                                          :product_reference_id => product_references(:product_reference2).id)
    
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
    order.save
    
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
    dn.associated_quote.quotes_product_references.each do |ref|
      dn.delivery_notes_quotes_product_references.build(:quotes_product_reference_id => ref.id,
                                                        :quantity => ref.quantity)
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
end
