namespace :osirails do
  namespace :db do
    desc "Populate the database with simple entries (only use for development)"
    task :load_development_data => :environment do
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
                                                    :establishment_type_id => EstablishmentType.all[2],
                                                    :siret_number => "56735321547896")
      establishment2 = customer.build_establishment(:name => "Super Etablissement",
                                                    :establishment_type_id => EstablishmentType.last.id,
                                                    :siret_number => "35478965321567")
      head_office.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment1.build_address(:street_name => "2 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment2.build_address(:street_name => "3 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Marie", :zip_code => "97438")
      
      customer.save!
      
      # default contacts
      contact1 = Contact.create! :first_name => "Jean-Jacques", :last_name => "Dupont",  :email => "jean-jacques@dupont.fr", :job => "Commercial", :gender => "M"
      contact2 = Contact.create! :first_name => "Pierre-Paul",  :last_name => "Dupond",  :email => "pierre-paul@dupond.fr",  :job => "Commercial", :gender => "M"
      contact3 = Contact.create! :first_name => "Nicolas",      :last_name => "Hoareau", :email => "nicolas@hoarau.fr",      :job => "Commercial", :gender => "M"
      contact4 = Contact.create! :first_name => "fredo",      :last_name => "Hoareau", :email => "fredo@hoarau.fr",      :job => "Commercial", :gender => "M"
      
      # create numbers and assign numbers to contacts
      contact1.numbers.build(:number => "692246801", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      contact2.numbers.build(:number => "262357913", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
      contact3.numbers.build(:number => "918729871", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      contact4.numbers.build(:number => "918559871", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
      contact1.save!
      contact2.save!
      contact3.save!
      contact4.save!

      # default activity sectors
      ActivitySectorReference.create! :code => "10.11Z", :activity_sector        => ActivitySector.find_or_create_by_name(:name => "Industries Alimentaires"),
                                                         :custom_activity_sector => CustomActivitySector.find_or_create_by_name(:name => "Alimentation")
        
      ActivitySectorReference.create! :code => "13.10Z", :activity_sector        => ActivitySector.create!(:name => "Fabrication de textiles"),
                                                         :custom_activity_sector => CustomActivitySector.create!(:name => "Textile/Habillement")
        
      ActivitySectorReference.create! :code => "42.11Z", :activity_sector        => ActivitySector.create!(:name => "Génie civil"),
                                                         :custom_activity_sector => CustomActivitySector.create!(:name => "Construction")
        
      ActivitySectorReference.create! :code => "27.40Z", :activity_sector        => ActivitySector.create!(:name => "Fabrication d'équipements électriques"),
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
      head_office.contacts << contact4
      establishment1.contacts << contact1
      establishment2.contacts << contact2
      supplier1.contacts << contact3
      
      # default subcontractors
      subcontractor = Subcontractor.create! :name => "Sous traitant par défaut", :siret_number => "12345678912345", :activity_sector_reference_id => ActivitySectorReference.first.id, :legal_form_id => LegalForm.first.id
      subcontractor.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      subcontractor.build_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      subcontractor.save!
      
      # default commodity categories
      metal = CommodityCategory.create! :name => "Metal"
      toles = CommodityCategory.create! :name => "Tôles", :commodity_category_id => metal.id, :unit_measure_id => UnitMeasure.first.id
      tubes = CommodityCategory.create! :name => "Tubes", :commodity_category_id => metal.id, :unit_measure_id => UnitMeasure.first.id
      
      # default product reference categories
      famille1 = ProductReferenceCategory.create! :name => "Famille 1"
      famille2 = ProductReferenceCategory.create! :name => "Famille 2"
      famille3 = ProductReferenceCategory.create! :name => "Famille 3"
      
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
      
      # default product references
      reference111 = ProductReference.create! :name => "Reference 1.1.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 10, :production_time => 2, :delivery_cost_manpower => 20, :delivery_time => 3,   :reference => "XKTO89", :vat => Vat.all.rand.rate
      reference112 = ProductReference.create! :name => "Reference 1.1.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 20, :production_time => 2, :delivery_cost_manpower => 10, :delivery_time => 1.5, :reference => "XKTO90", :vat => Vat.all.rand.rate
      reference113 = ProductReference.create! :name => "Reference 1.1.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 30, :production_time => 3, :delivery_cost_manpower => 30, :delivery_time => 3,   :reference => "XKTO91", :vat => Vat.all.rand.rate
     
      ProductReference.create! :name => "Reference 1.2.1", :description => "Description de la référence 1.2.1", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 10, :production_time => 2.7,  :delivery_cost_manpower => 30, :delivery_time => 2,   :reference => "XKTO92", :vat => Vat.all.rand.rate
      ProductReference.create! :name => "Reference 1.2.2", :description => "Description de la référence 1.2.2", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 20, :production_time => 4,    :delivery_cost_manpower => 40, :delivery_time => 4,   :reference => "XKTO93", :vat => Vat.all.rand.rate
      ProductReference.create! :name => "Reference 1.2.3", :description => "Description de la référence 1.2.3", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 30, :production_time => 4,    :delivery_cost_manpower => 20, :delivery_time => 2,   :reference => "XKTO94", :vat => Vat.all.rand.rate
      ProductReference.create! :name => "Reference 1.3.1", :description => "Description de la référence 1.3.1", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 10, :production_time => 1,    :delivery_cost_manpower => 10, :delivery_time => 3.5, :reference => "XKTO95", :vat => Vat.all.rand.rate
      ProductReference.create! :name => "Reference 1.3.2", :description => "Description de la référence 1.3.2", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 20, :production_time => 5,    :delivery_cost_manpower => 20, :delivery_time => 1,   :reference => "XKTO96", :vat => Vat.all.rand.rate
      ProductReference.create! :name => "Reference 1.3.3", :description => "Description de la référence 1.3.3", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 30, :production_time => 2.9,  :delivery_cost_manpower => 10, :delivery_time => 2.3, :reference => "XKTO97", :vat => Vat.all.rand.rate
      
      # default commodities and their supplier_supplies
      galva   = Commodity.create! :name => "Galva 1500x3000x2",      :reference => "glv2", :measure => "4.50", :unit_mass => "70.65",  :commodity_category_id => toles.id, :threshold => 5
      galva2  = Commodity.create! :name => "Galva 1500x3000x3",      :reference => "glv3", :measure => "4.50", :unit_mass => "105.98", :commodity_category_id => toles.id, :threshold => 1
      galva3  = Commodity.create! :name => "Galva rond Ø20x2 Lg 6m", :reference => "glv6", :measure => "6",    :unit_mass => "5.32",   :commodity_category_id => tubes.id, :threshold => 18
  
      SupplierSupply.create! :supply_id       => galva.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "glv",
                             :name            => "galva",
                             :fob_unit_price  => 10,
                             :tax_coefficient => 1,
                             :lead_time       => 15
  
      SupplierSupply.create! :supply_id       => galva.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "galv",
                             :name            => "galva_it",
                             :fob_unit_price  => 11,
                             :tax_coefficient => 2,
                             :lead_time       => 18
  
      SupplierSupply.create! :supply_id       => galva2.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "glv2",
                             :name            => "galva2",
                             :fob_unit_price  => 12,
                             :tax_coefficient => 50,
                             :lead_time       => 15
  
      SupplierSupply.create! :supply_id       => galva2.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "galv2",
                             :name            => "galva_it2",
                             :fob_unit_price  => 25,
                             :tax_coefficient => 3,
                             :lead_time       => 18
  
      SupplierSupply.create! :supply_id       => galva3.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "glv3",
                             :name            => "galva",
                             :fob_unit_price  => 15,
                             :tax_coefficient => 4,
                             :lead_time       => 15
  
      SupplierSupply.create! :supply_id       => galva3.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "galv3",
                             :name            => "galva_it3",
                             :fob_unit_price  => 9,
                             :tax_coefficient => 0,
                             :lead_time       => 18
  
      # default consumable categories
      root      = ConsumableCategory.create! :name => "Root"
      child_one = ConsumableCategory.create! :name => "Intermédiaire", :consumable_category_id => root.id, :unit_measure_id => UnitMeasure.first.id
      child_two = ConsumableCategory.create! :name => "Léger",         :consumable_category_id => root.id, :unit_measure_id => UnitMeasure.first.id
  
      # default consumables and their supplier_supplies
      pvc   = Consumable.create! :name => "PVC 1500x3000x2", :reference => "pvc2", :measure => "6.50", :unit_mass => "10.65",  :consumable_category_id => child_one.id, :threshold => 2
      pvc2  = Consumable.create! :name => "PVC 1500x3000x3", :reference => "pvc3", :measure => "6.50", :unit_mass => "10.98",  :consumable_category_id => child_one.id, :threshold => 10
      vis   = Consumable.create! :name => "Vis Ø20x2 Lg 6m", :reference => "vis6", :measure => "0.5",  :unit_mass => "0.8",    :consumable_category_id => child_two.id, :threshold => 40
  
      SupplierSupply.create! :supply_id       => pvc.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "pvc",
                             :name            => "pvc-1",
                             :fob_unit_price  => 8,
                             :tax_coefficient => 5,
                             :lead_time       => 20
  
      SupplierSupply.create! :supply_id       => pvc.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "pvc_it",
                             :name            => "pvc-it-1",
                             :fob_unit_price  => 10,
                             :tax_coefficient => 1,
                             :lead_time       => 15
  
      SupplierSupply.create! :supply_id       => pvc2.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "pvc2",
                             :name            => "pvc-12",
                             :fob_unit_price  => 13,
                             :tax_coefficient => 8,
                             :lead_time       => 13
  
      SupplierSupply.create! :supply_id       => pvc2.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "pvc_it",
                             :name            => "pvc-it-12",
                             :fob_unit_price  => 12,
                             :tax_coefficient => 1,
                             :lead_time       => 12
  
      SupplierSupply.create! :supply_id       => vis.id,
                             :supplier_id     => supplier1.id,
                             :reference       => "vis2",
                             :name            => "vis-12",
                             :fob_unit_price  => 7,
                             :tax_coefficient => 0,
                             :lead_time       => 15
  
      SupplierSupply.create! :supply_id       => vis.id,
                             :supplier_id     => supplier2.id,
                             :reference       => "vis_it",
                             :name            => "vis-it-12",
                             :fob_unit_price  => 14,
                             :tax_coefficient => 0,
                             :lead_time       => 11
                             
      # default stock_flows
      StockInput.create! :supply_id       => galva.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
                         
      StockInput.create! :supply_id       => galva.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => galva2.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => galva2.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => galva3.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => galva3.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
      
      StockInput.create! :supply_id       => pvc.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => pvc.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => pvc2.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => pvc2.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => vis.id,
                         :supplier_id     => supplier1.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
  
      StockInput.create! :supply_id       => vis.id,
                         :supplier_id     => supplier2.id,
                         :adjustment      => true,
                         :fob_unit_price  => 10,
                         :tax_coefficient => 0,
                         :quantity        => 15,
                         :created_at      => Date.yesterday.to_datetime
      
      # default calendars and events
      calendar1 = Calendar.create! :user_id => User.first.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
      
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.day,  :end_at => DateTime.now + 1.day + 2.hours
      
      # default employees
      john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => Service.first.id, :civility_id => Civility.first.id, :family_situation_id => FamilySituation.first.id, :qualification => "Inconnu"
      john.numbers.build(:number => "692123456", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      john.numbers.build(:number => "262987654", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
      john.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      john.build_iban(:bank_name => "Bred", :account_name => "John DOE" , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      john.save!
      john.jobs << Job.first
      john.user.roles << Role.first
      john.user.enabled = true
      john.user.save!
      john.job_contract.update_attributes(:start_date => Date.today, :end_date => Date.today + 1.years, :job_contract_type_id => JobContractType.first.id, :employee_state_id => EmployeeState.first.id, :salary => "2000")
      
      ###########
      first_names = %W( pierre paul jacques jean fabrice patricia marie julie isabelle )
      last_names  = %W( dupont hoarau turpin payet grondin boyer)
      numbers     = %W( 18 20 22 23 30 35 40 45 )
      addresses   = %W( rosiers palmiers lauriers Champs-Elizées cocotiers )
      countries   = %W( Reunion France Espagne Italie EtatsUnis )
      cities      = %W( SaintDenis Paris Madrid Rome NewYork )
      banks       = %W( Bred BR CreditAgricole BFC )
      ###########
      20.times do |i|
        employee = john.clone
        employee.first_name = first_names.rand
        employee.last_name = last_names.rand
        employee.email = "#{employee.first_name}@#{employee.last_name}.com"
        employee.birth_date = Date.today - numbers.rand.to_i.years - numbers.rand.to_i.days
        employee.build_address(:street_name => "#{numbers.rand} rue des #{addresses.rand}", :country_name => "#{countries.rand}", :city_name => "#{cities.rand}", :zip_code => rand(99999).to_s)
        employee.build_iban(:bank_name => banks.rand, :account_name => employee.fullname , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
        employee.service = Service.all.rand
        employee.save!
        [1,1,1,1,1,1,1,2,2,3].rand.times do |j|
          job = Job.all.rand
          ( employee.jobs << job ) unless employee.jobs.include?(job)
        end
      end
  
      # default calendar
      calendar_john_doe = Calendar.create! :user_id => john.user.id, :name => "Calendrier de John doe", :color => "blue", :title => "Calendrier de John Doe"
      Event.create! :calendar_id => calendar_john_doe.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
      
      # defauts memorandums
      m1  = Memorandum.create! :title => 'Note de service 1',   :subject      => 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor.',
                                                                :text         => 'Maecenas adipiscing ante non diam sodales hendrerit. Ut velit mauris, egestas sed, gravida nec, ornare ut, mi. Aenean ut orci vel massa suscipit pulvinar. Nulla sollicitudin. Fusce varius, ligula non tempus aliquam, nunc turpis ullamcorper nibh, in tempus sapien eros vitae ligula. Pellentesque rhoncus nunc et augue. Integer id felis. Curabitur aliquet pellentesque diam. Integer quis metus vitae elit lobortis egestas. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi vel erat non mauris convallis vehicula. Nulla et sapien. Integer tortor tellus, aliquam faucibus, convallis id, congue eu, quam. Mauris ullamcorper felis vitae erat. Proin feugiat, augue non elementum posuere, metus purus iaculis lectus, et tristique ligula justo vitae magna. Aliquam convallis sollicitudin purus. Praesent aliquam, enim at fermentum mollis, ligula massa adipiscing nisl, ac euismod nibh nisl eu lectus. Fusce vulputate sem at sapien. Vivamus leo. Aliquam euismod libero eu enim. Nulla nec felis sed leo placerat imperdiet. Aenean suscipit nulla in justo. Suspendisse cursus rutrum augue. Nulla tincidunt tincidunt mi. Curabitur iaculis, lorem vel rhoncus faucibus, felis magna fermentum augue, et ultricies lacus lorem varius purus. Curabitur eu amet.',
                                                                :signature    => 'le Président',
                                                                :user_id      => 3,
                                                                :published_at => Time.now - 3.months
      m2  = Memorandum.create! :title => 'Note de service 2',   :subject      => 'Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat.',
                                                                :text         => 'Maecenas adipiscing ante non diam sodales hendrerit. Ut velit mauris, egestas sed, gravida nec, ornare ut, mi. Aenean ut orci vel massa suscipit pulvinar. Nulla sollicitudin. Fusce varius, ligula non tempus aliquam, nunc turpis ullamcorper nibh, in tempus sapien eros vitae ligula. Pellentesque rhoncus nunc et augue. Integer id felis. Curabitur aliquet pellentesque diam. Integer quis metus vitae elit lobortis egestas. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi vel erat non mauris convallis vehicula. Nulla et sapien. Integer tortor tellus, aliquam faucibus, convallis id, congue eu, quam. Mauris ullamcorper felis vitae erat. Proin feugiat, augue non elementum posuere, metus purus iaculis lectus, et tristique ligula justo vitae magna. Aliquam convallis sollicitudin purus. Praesent aliquam, enim at fermentum mollis, ligula massa adipiscing nisl, ac euismod nibh nisl eu lectus. Fusce vulputate sem at sapien. Vivamus leo. Aliquam euismod libero eu enim. Nulla nec felis sed leo placerat imperdiet. Aenean suscipit nulla in justo. Suspendisse cursus rutrum augue. Nulla tincidunt tincidunt mi. Curabitur iaculis, lorem vel rhoncus faucibus, felis magna fermentum augue, et ultricies lacus lorem varius purus. Curabitur eu amet.',
                                                                :signature    => 'le Président',
                                                                :user_id      => 3,
                                                                :published_at => Time.now - 2.months
      m3  = Memorandum.create! :title => 'Note de service 3',   :subject      => 'Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim. Pellentesque congue. Ut in risus volutpat libero pharetra tempor. Cras vestibulum bibendum augue.',
                                                                :text         => 'Maecenas adipiscing ante non diam sodales hendrerit. Ut velit mauris, egestas sed, gravida nec, ornare ut, mi. Aenean ut orci vel massa suscipit pulvinar. Nulla sollicitudin. Fusce varius, ligula non tempus aliquam, nunc turpis ullamcorper nibh, in tempus sapien eros vitae ligula. Pellentesque rhoncus nunc et augue. Integer id felis. Curabitur aliquet pellentesque diam. Integer quis metus vitae elit lobortis egestas. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi vel erat non mauris convallis vehicula. Nulla et sapien. Integer tortor tellus, aliquam faucibus, convallis id, congue eu, quam. Mauris ullamcorper felis vitae erat. Proin feugiat, augue non elementum posuere, metus purus iaculis lectus, et tristique ligula justo vitae magna. Aliquam convallis sollicitudin purus. Praesent aliquam, enim at fermentum mollis, ligula massa adipiscing nisl, ac euismod nibh nisl eu lectus. Fusce vulputate sem at sapien. Vivamus leo. Aliquam euismod libero eu enim. Nulla nec felis sed leo placerat imperdiet. Aenean suscipit nulla in justo. Suspendisse cursus rutrum augue. Nulla tincidunt tincidunt mi. Curabitur iaculis, lorem vel rhoncus faucibus, felis magna fermentum augue, et ultricies lacus lorem varius purus. Curabitur eu amet.',
                                                                :signature    => 'le Président',
                                                                :user_id      => 3,
                                                                :published_at => Time.now - 1.months
      
      m1.services << Service.first
      m2.services << Service.first
      m3.services << Service.first
      
      # default orders
      order1 = Order.new(:title => "VISUEL NUMERIQUE GRAND FORMAT", :customer_needs => "1 visuel 10000 x 4000", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 10.days, :previsional_delivery => DateTime.now + 20.days)
      order1.build_bill_to_address(order1.customer.bill_to_address.attributes)
      order1.order_contact_id = Customer.first.contacts.first.id
      establishment = order1.customer.establishments.first
      order1.ship_to_addresses.build(:establishment_id => establishment.id, :establishment_name => establishment.name, :should_create => 1).build_address(establishment.address.attributes)
      order1.save!
      
      order2 = Order.new(:title => "DRAPEAUX", :customer_needs => "4 drapeaux 400 x 700", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 5.days, :previsional_delivery => DateTime.now + 14.days)
      order2.build_bill_to_address(order2.customer.bill_to_address.attributes)
      order2.order_contact_id = Customer.first.contacts.first.id
      establishment = order2.customer.establishments.first
      order2.ship_to_addresses.build(:establishment_id => establishment.id, :establishment_name => establishment.name, :should_create => 1).build_address(establishment.address.attributes)
      order2.save!
      
      # default products
      order1.products.build(:reference => "01010101", :name => "Produit 1.1.1.1", :description => "Description du produit 1.1.1.1", :product_reference_id => reference111.id, :dimensions => "1000x2000", :quantity => 1).save!
      order1.products.build(:reference => "01010201", :name => "Produit 1.1.2.1", :description => "Description du produit 1.1.2.1", :product_reference_id => reference112.id, :dimensions => "1000x3000", :quantity => 2).save!
      order1.products.build(:reference => "01010301", :name => "Produit 1.1.3.1", :description => "Description du produit 1.1.3.1", :product_reference_id => reference113.id, :dimensions => "2000x4000", :quantity => 3).save!
      order2.products.build(:reference => "01010202", :name => "Produit 1.1.2.2", :description => "Description du produit 1.1.2.2", :product_reference_id => reference111.id, :dimensions => "2000x2000", :quantity => 1).save!
      order2.products.build(:reference => "01010302", :name => "Produit 1.1.3.2", :description => "Description du produit 1.1.3.2", :product_reference_id => reference112.id, :dimensions => "2000x5000", :quantity => 2).save!
      order2.products.build(:reference => "01010303", :name => "Produit 1.1.3.3", :description => "Description du produit 1.1.3.3", :product_reference_id => reference113.id, :dimensions => "5000x1000", :quantity => 3).save!
      
      # default quote
      quote = order1.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days', :creator_id => User.first.id)
      quote.quote_contact_id = order1.all_contacts.first.id
      quote.build_ship_to_address(Address.first.attributes)
      quote.build_bill_to_address(Address.last.attributes)
      order1.products.each do |product|
        quote.quote_items.build(:product_id   => product.id,
                                :name         => product.name,
                                :description  => product.description,
                                :dimensions   => product.dimensions,
                                :quantity     => product.quantity,
                                :unit_price   => (product.quantity * rand * 10000).round,
                                :prizegiving  => (rand * 10).round,
                                :vat          => Vat.all.rand.rate)
      end
      quote.save!
      quote.confirm
      quote.send_to_customer(:sended_on => Date.today, :send_quote_method_id => SendQuoteMethod.first.id)
      attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
      quote.sign(:signed_on => Date.today, :order_form_type_id => OrderFormType.first.id, :order_form => attachment)
      
      # default mockups
      mockup = Order.first.mockups.create!  :name                 => "Sample", 
                                            :description          => "Sample de maquette par défaut", 
                                            :graphic_unit_measure => GraphicUnitMeasure.first, 
                                            :creator              => User.first, 
                                            :mockup_type          => MockupType.first, 
                                            :product              => Order.first.products.first,
                                            :graphic_item_version_attributes => { :image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") ) }
      
      mockup.graphic_item_version_attributes = {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
                                                :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") )}      
      mockup.save!
      
      mockup2 = Order.first.mockups.create! :name                 => "Sample 2", 
                                            :description          => "Sample 2 de maquette par défaut", 
                                            :graphic_unit_measure => GraphicUnitMeasure.last, 
                                            :creator              => User.last, 
                                            :mockup_type          => MockupType.last, 
                                            :product              => Order.first.products.last,
                                            :graphic_item_version_attributes => { :image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
                                                                                  :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") ) }
      
      mockup2.graphic_item_version_attributes = { :image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") ) }
      mockup2.save!
      
      Vehicle.create! :service_id => Service.first.id,  :job_id => Job.first.id, :employee_id => Employee.first.id, :supplier_id => Supplier.first.id, :name => "Ford Fiesta",    :serial_number => "123 ABC 974", :description => "Véhicule utilitaire",    :purchase_date => Date.today - 1.year,   :purchase_price => "12000"
      Vehicle.create! :service_id => Service.last.id,   :job_id => Job.last.id,  :employee_id => Employee.last.id,  :supplier_id => Supplier.last.id,  :name => "Renault Magnum", :serial_number => "456 DEF 974", :description => "Camion longue distance", :purchase_date => Date.today - 6.months, :purchase_price => "130000"
    end
  end
end
