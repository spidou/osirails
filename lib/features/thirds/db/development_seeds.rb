# default factors
cga = Factor.create!(:name => "CGA", :fullname => "Compagnie Générale d'Affacturage")

# default customers and establishements
customer = Customer.new(:name => "Client par défaut", :legal_form_id => LegalForm.first.id, :activated => true,
                        :customer_solvency_id => CustomerSolvency.first.id ,:customer_grade_id => CustomerGrade.first.id)

customer.build_bill_to_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
head_office = customer.build_head_office(:name => "Mon siege social",
                                         :establishment_type_id => EstablishmentType.first.id,
                                         :siret_number => "53215673547896")
establishment1 = customer.build_establishment(:name => "Mon Etablissement",
                                              :establishment_type_id => EstablishmentType.all[1].id,
                                              :siret_number => "56735321547896")
establishment2 = customer.build_establishment(:name => "Super Etablissement",
                                              :establishment_type_id => EstablishmentType.all[2].id,
                                              :siret_number => "35478965321567")
head_office.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
establishment1.build_address(:street_name => "2 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
establishment2.build_address(:street_name => "3 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Marie", :zip_code => "97438")

customer.save!

# default activity sectors
ActivitySectorReference.create! :code => "10.11Z", :activity_sector        => ActivitySector.find_or_create_by_name(:name => "Industries Alimentaires"),
                                                   :custom_activity_sector => CustomActivitySector.find_or_create_by_name(:name => "Alimentation")
  
ActivitySectorReference.create! :code => "13.10Z", :activity_sector        => ActivitySector.find_or_create_by_name(:name => "Fabrication de textiles"),
                                                   :custom_activity_sector => CustomActivitySector.find_or_create_by_name(:name => "Textile/Habillement")
  
ActivitySectorReference.create! :code => "42.11Z", :activity_sector        => ActivitySector.find_or_create_by_name(:name => "Génie civil"),
                                                   :custom_activity_sector => CustomActivitySector.find_or_create_by_name(:name => "Construction")
  
ActivitySectorReference.create! :code => "27.40Z", :activity_sector        => ActivitySector.find_or_create_by_name(:name => "Fabrication d'équipements électriques"),
                                                   :custom_activity_sector => nil

# default suppliers
supplier1 = Supplier.create! :name => "Store Concept", :siret_number => "12345678912346", :activity_sector_reference_id => ActivitySectorReference.first.id, :legal_form_id => LegalForm.first.id
supplier1.create_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
supplier1.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
supplier1.save!

supplier2 = Supplier.create! :name => "Globo", :siret_number => "12345678912348", :activity_sector_reference_id => ActivitySectorReference.first.id, :legal_form_id => LegalForm.first.id
supplier2.create_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
supplier2.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
supplier2.save!

# assign contacts to establishments and suppliers
establishment1.contacts << Contact.find(1)
establishment2.contacts << Contact.find(2)
supplier1.contacts << Contact.find(3)
