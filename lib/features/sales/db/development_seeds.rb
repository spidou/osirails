# default subcontractors
subcontractor = Subcontractor.create! :name => "Sous traitant par défaut", :siret_number => "12345678912345", :activity_sector_reference_id => ActivitySectorReference.first.id, :legal_form_id => LegalForm.first.id
subcontractor.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
subcontractor.build_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
subcontractor.save!

# default product reference categories
famille1 = ProductReferenceCategory.create! :reference => "FA1", :name => "Famille 1"
famille2 = ProductReferenceCategory.create! :reference => "FA2", :name => "Famille 2"
famille3 = ProductReferenceCategory.create! :reference => "FA3", :name => "Famille 3"

sous_famille11 = ProductReferenceCategory.create! :name => "Sous famille 1.1", :product_reference_category_id => famille1.id
sous_famille12 = ProductReferenceCategory.create! :name => "Sous famille 1.2", :product_reference_category_id => famille1.id
sous_famille13 = ProductReferenceCategory.create! :name => "Sous famille 1.3", :product_reference_category_id => famille1.id

ProductReferenceCategory.create! :name => "Sous famille 2.4", :product_reference_category_id => famille2.id
ProductReferenceCategory.create! :name => "Sous famille 2.1", :product_reference_category_id => famille2.id
ProductReferenceCategory.create! :name => "Sous famille 2.2", :product_reference_category_id => famille2.id
ProductReferenceCategory.create! :name => "Sous famille 2.3", :product_reference_category_id => famille2.id
ProductReferenceCategory.create! :name => "Sous famille 3.1", :product_reference_category_id => famille3.id
ProductReferenceCategory.create! :name => "Sous famille 3.2", :product_reference_category_id => famille3.id
ProductReferenceCategory.create! :name => "Sous famille 3.3", :product_reference_category_id => famille3.id

## default product references
#reference111 = ProductReference.create! :name => "Reference 1.1.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 10, :production_time => 2, :delivery_cost_manpower => 20, :delivery_time => 3,   :reference => "XKTO89", :vat => Vat.all.rand.rate
#reference112 = ProductReference.create! :name => "Reference 1.1.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 20, :production_time => 2, :delivery_cost_manpower => 10, :delivery_time => 1.5, :reference => "XKTO90", :vat => Vat.all.rand.rate
#reference113 = ProductReference.create! :name => "Reference 1.1.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 30, :production_time => 3, :delivery_cost_manpower => 30, :delivery_time => 3,   :reference => "XKTO91", :vat => Vat.all.rand.rate
#
#ProductReference.create! :name => "Reference 1.2.1", :description => "Description de la référence 1.2.1", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 10, :production_time => 2.7,  :delivery_cost_manpower => 30, :delivery_time => 2,   :reference => "XKTO92", :vat => Vat.all.rand.rate
#ProductReference.create! :name => "Reference 1.2.2", :description => "Description de la référence 1.2.2", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 20, :production_time => 4,    :delivery_cost_manpower => 40, :delivery_time => 4,   :reference => "XKTO93", :vat => Vat.all.rand.rate
#ProductReference.create! :name => "Reference 1.2.3", :description => "Description de la référence 1.2.3", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 30, :production_time => 4,    :delivery_cost_manpower => 20, :delivery_time => 2,   :reference => "XKTO94", :vat => Vat.all.rand.rate
#ProductReference.create! :name => "Reference 1.3.1", :description => "Description de la référence 1.3.1", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 10, :production_time => 1,    :delivery_cost_manpower => 10, :delivery_time => 3.5, :reference => "XKTO95", :vat => Vat.all.rand.rate
#ProductReference.create! :name => "Reference 1.3.2", :description => "Description de la référence 1.3.2", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 20, :production_time => 5,    :delivery_cost_manpower => 20, :delivery_time => 1,   :reference => "XKTO96", :vat => Vat.all.rand.rate
#ProductReference.create! :name => "Reference 1.3.3", :description => "Description de la référence 1.3.3", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 30, :production_time => 2.9,  :delivery_cost_manpower => 10, :delivery_time => 2.3, :reference => "XKTO97", :vat => Vat.all.rand.rate

## default orders
#order1 = Order.new(:title => "VISUEL NUMERIQUE GRAND FORMAT", :customer_needs => "1 visuel 10000 x 4000", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 10.days, :previsional_delivery => DateTime.now + 20.days)
#order1.build_bill_to_address(order1.customer.bill_to_address.attributes)
#order1.contacts << Customer.first.contacts.first
#establishment = order1.customer.establishments.first
#order1.ship_to_addresses.build(:establishment_id => establishment.id, :establishment_name => establishment.name, :should_create => 1).build_address(establishment.address.attributes)
#order1.save!
#
#order2 = Order.new(:title => "DRAPEAUX", :customer_needs => "4 drapeaux 400 x 700", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 5.days, :previsional_delivery => DateTime.now + 14.days)
#order2.build_bill_to_address(order2.customer.bill_to_address.attributes)
#order2.contacts << Customer.first.contacts.first
#establishment = order2.customer.establishments.first
#order2.ship_to_addresses.build(:establishment_id => establishment.id, :establishment_name => establishment.name, :should_create => 1).build_address(establishment.address.attributes)
#order2.save!
#
## default end_products
#order1.end_products.create! :name => "Produit 1.1.1.1", :description => "Description du produit 1.1.1.1", :product_reference_id => reference111.id, :quantity => 1
#order1.end_products.create! :name => "Produit 1.1.2.1", :description => "Description du produit 1.1.2.1", :product_reference_id => reference112.id, :quantity => 2
#order1.end_products.create! :name => "Produit 1.1.3.1", :description => "Description du produit 1.1.3.1", :product_reference_id => reference113.id, :quantity => 3
#order2.end_products.create! :name => "Produit 1.1.2.2", :description => "Description du produit 1.1.2.2", :product_reference_id => reference111.id, :quantity => 1
#order2.end_products.create! :name => "Produit 1.1.3.2", :description => "Description du produit 1.1.3.2", :product_reference_id => reference112.id, :quantity => 2
#order2.end_products.create! :name => "Produit 1.1.3.3", :description => "Description du produit 1.1.3.3", :product_reference_id => reference113.id, :quantity => 3
#
## default quote
#quote = order1.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days', :creator_id => User.first.id)
#quote.contacts << order1.contacts.first
#quote.build_ship_to_address(Address.first.attributes)
#quote.build_bill_to_address(Address.last.attributes)
#order1.end_products.each do |end_product|
#  quote.quote_items.build(:end_product_id  => end_product.id,
#                          :name            => end_product.name,
#                          :description     => end_product.description,
#                          :dimensions      => end_product.dimensions,
#                          :quantity        => end_product.quantity,
#                          :unit_price      => (end_product.quantity * rand * 10000).round,
#                          :prizegiving     => (rand * 10).round,
#                          :vat             => Vat.all.rand.rate)
#end
#quote.save!
#quote.confirm
#quote.send_to_customer(:sended_on => Date.today, :send_quote_method_id => SendQuoteMethod.first.id)
#attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
#quote.sign(:signed_on => Date.today, :order_form_type_id => OrderFormType.first.id, :order_form => attachment)
#
## default mockups
#mockup = order1.mockups.create!  :name                 => "Sample", 
#                                 :description          => "Sample de maquette par défaut", 
#                                 :graphic_unit_measure => GraphicUnitMeasure.first, 
#                                 :creator              => User.first, 
#                                 :mockup_type          => MockupType.first, 
#                                 :end_product          => order1.end_products.first,
#                                 :graphic_item_version_attributes => { :image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") ) }
#
#mockup.graphic_item_version_attributes = {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
#                                          :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") )}      
#mockup.save!
#
#mockup2 = order1.mockups.create! :name                 => "Sample 2", 
#                                 :description          => "Sample 2 de maquette par défaut", 
#                                 :graphic_unit_measure => GraphicUnitMeasure.last, 
#                                 :creator              => User.last, 
#                                 :mockup_type          => MockupType.last, 
#                                 :end_product          => order1.end_products.last,
#                                 :graphic_item_version_attributes => { :image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
#                                                                            :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") ) }
#
#mockup2.graphic_item_version_attributes = { :image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") ) }
#mockup2.save!
