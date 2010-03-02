namespace :osirails do
  namespace :db do
    desc "Populate the database"
    task :populate => :environment do
      # default civilities
      Civility.create! :name => "Mr"
      Civility.create! :name => "Mme"
      Civility.create! :name => "Mademoiselle"
      
      # default family situations
      FamilySituation.create! :name => "Célibataire"
      FamilySituation.create! :name => "Marié(e)"
      FamilySituation.create! :name => "Veuf/Veuve"
      FamilySituation.create! :name => "Divorcé(e)"
      FamilySituation.create! :name => "Pacsé(e)"
      
      # default number types
      NumberType.create! :name => "Mobile"
      NumberType.create! :name => "Fixe"
      NumberType.create! :name => "Fax"
      NumberType.create! :name => "Mobile Professionnel"
      NumberType.create! :name => "Fixe Professionnel"
      NumberType.create! :name => "Fax Professionnel"
      
      # default employee states
      EmployeeState.create! :name => "Titulaire",       :active => 1
      EmployeeState.create! :name => "Stagiaire",       :active => 1
      EmployeeState.create! :name => "Licencié(e)",     :active => 0
      EmployeeState.create! :name => "Démissionnaire",  :active => 0
      
      # default job contract types
      JobContractType.create! :name => "CDI", :limited => 0
      JobContractType.create! :name => "CDD", :limited => 1
      
      # default leave types
      LeaveType.create! :name => "Congés payés"
      LeaveType.create! :name => "Congé maladie"
      LeaveType.create! :name => "Congé maternité"
      LeaveType.create! :name => "Congé paternité"
      LeaveType.create! :name => "Congés spéciaux"
      LeaveType.create! :name => "Récupération"
      
      # default countries
      france          = Country.create! :name => "FRANCE",      :code => "fr"
      reunion         = Country.create! :name => "REUNION",     :code => "fr"
      spain           = Country.create! :name => "ESPAGNE",     :code => "es"
      united_kingdom  = Country.create! :name => "ANGLETERRE",  :code => "gb"
      germany         = Country.create! :name => "ALLEMAGNE",   :code => "de"
      japan           = Country.create! :name => "JAPON",       :code => "jp"
      china           = Country.create! :name => "CHINE",       :code => "cn"
      united_states   = Country.create! :name => "ETATS-UNIS",  :code => "us"
      canada          = Country.create! :name => "CANADA",      :code => "ca"
      
      # default indicatives
      Indicative.create! :indicative => "+262", :country_id => reunion.id
      Indicative.create! :indicative => "+33",  :country_id => france.id 
      Indicative.create! :indicative => "+34",  :country_id => spain.id
      Indicative.create! :indicative => "+44",  :country_id => united_kingdom.id
      Indicative.create! :indicative => "+49",  :country_id => germany.id
      Indicative.create! :indicative => "+81",  :country_id => japan.id
      Indicative.create! :indicative => "+86",  :country_id => china.id
      Indicative.create! :indicative => "+1",   :country_id => united_states.id
      
      # default cities
      City.create! :name => "BRAS PANON",               :zip_code => "97412", :country_id => reunion.id
      City.create! :name => "CILAOS",                   :zip_code => "97413", :country_id => reunion.id
      City.create! :name => "ENTRE DEUX",               :zip_code => "97414", :country_id => reunion.id
      City.create! :name => "ETANG SALE",               :zip_code => "97427", :country_id => reunion.id
      City.create! :name => "LA CHALOUPE",              :zip_code => "97416", :country_id => reunion.id
      City.create! :name => "LA MONTAGNE",              :zip_code => "97417", :country_id => reunion.id
      City.create! :name => "LA NOUVELLE",              :zip_code => "97428", :country_id => reunion.id
      City.create! :name => "LA PLAINE DES CAFRES",     :zip_code => "97418", :country_id => reunion.id
      City.create! :name => "LA PLAINE DES PALMISTES",  :zip_code => "97431", :country_id => reunion.id
      City.create! :name => "LA POSSESSION",            :zip_code => "97419", :country_id => reunion.id
      City.create! :name => "LA RIVIERE",               :zip_code => "97421", :country_id => reunion.id
      City.create! :name => "LA SALINE",                :zip_code => "97422", :country_id => reunion.id
      City.create! :name => "LE GUILLAUME",             :zip_code => "97423", :country_id => reunion.id
      City.create! :name => "LE PITON ST LEU",          :zip_code => "97424", :country_id => reunion.id
      City.create! :name => "LE PORT",                  :zip_code => "97420", :country_id => reunion.id
      City.create! :name => "LE TAMPON",                :zip_code => "97430", :country_id => reunion.id
      City.create! :name => "LES AVIRONS",              :zip_code => "97425", :country_id => reunion.id
      City.create! :name => "LES TROIS BASSINS",        :zip_code => "97426", :country_id => reunion.id
      City.create! :name => "PETITE ILE",               :zip_code => "97429", :country_id => reunion.id
      City.create! :name => "PLATEAU CAILLOUX",         :zip_code => "97460", :country_id => reunion.id
      City.create! :name => "RAVINE DES CABRIS",        :zip_code => "97432", :country_id => reunion.id
      City.create! :name => "SALAZIE",                  :zip_code => "97433", :country_id => reunion.id
      City.create! :name => "SAINT ANDRE",              :zip_code => "97440", :country_id => reunion.id
      City.create! :name => "SAINT BENOIT",             :zip_code => "97470", :country_id => reunion.id
      City.create! :name => "SAINT DENIS",              :zip_code => "97400", :country_id => reunion.id
      City.create! :name => "SAINT GILLES LES BAINS",   :zip_code => "97434", :country_id => reunion.id
      City.create! :name => "SAINT GILLES LES HAUTS",   :zip_code => "97435", :country_id => reunion.id
      City.create! :name => "SAINT JOSEPH",             :zip_code => "97480", :country_id => reunion.id
      City.create! :name => "SAINT LEU",                :zip_code => "97436", :country_id => reunion.id
      City.create! :name => "SAINT LOUIS",              :zip_code => "97450", :country_id => reunion.id
      City.create! :name => "SAINT PAUL",               :zip_code => "97411", :country_id => reunion.id
      City.create! :name => "SAINT PHILIPPE",           :zip_code => "97442", :country_id => reunion.id
      City.create! :name => "SAINT PIERRE",             :zip_code => "97410", :country_id => reunion.id
      City.create! :name => "SAINTE ANNE",              :zip_code => "97437", :country_id => reunion.id
      City.create! :name => "SAINTE CLOTILDE",          :zip_code => "97490", :country_id => reunion.id
      City.create! :name => "SAINTE MARIE",             :zip_code => "97438", :country_id => reunion.id
      City.create! :name => "SAINTE ROSE",              :zip_code => "97439", :country_id => reunion.id
      City.create! :name => "SAINTE SUZANNE",           :zip_code => "97441", :country_id => reunion.id
      
      # default services
      dg   = Service.create! :name => "Direction Générale"
      af   = Service.create! :name => "Administratif et Financier", :service_parent_id => dg.id
      com  = Service.create! :name => "Commercial",                 :service_parent_id => dg.id
      av   = Service.create! :name => "Achats/Ventes",              :service_parent_id => dg.id
      si   = Service.create! :name => "Informatique",               :service_parent_id => dg.id
      prod = Service.create! :name => "Production",                 :service_parent_id => dg.id
      deco = Service.create! :name => "Décor",                      :service_parent_id => prod.id
      pose = Service.create! :name => "Pose",                       :service_parent_id => prod.id
      
      # default jobs
      Job.create! :name => "Directeur Général",                     :responsible => true,  :service_id => dg.id
      Job.create! :name => "Directeur Commercial",                  :responsible => true,  :service_id => com.id
      Job.create! :name => "Commercial",                            :responsible => false, :service_id => com.id
      Job.create! :name => "Chargé d'affaires",                     :responsible => false, :service_id => com.id
      Job.create! :name => "Directeur Administratif et Financier",  :responsible => true,  :service_id => af.id
      Job.create! :name => "Secrétaire",                            :responsible => false, :service_id => af.id
      Job.create! :name => "Assistante de Direction",               :responsible => false, :service_id => af.id
      Job.create! :name => "Comptable",                             :responsible => false, :service_id => af.id
      Job.create! :name => "Assistante des Ressources Humaines",    :responsible => false, :service_id => af.id
      Job.create! :name => "Responsable des Achats/Ventes",         :responsible => true,  :service_id => av.id
      Job.create! :name => "Assistante des Achats/Ventes",          :responsible => false, :service_id => av.id
      Job.create! :name => "Ingénieur Informaticien",               :responsible => true,  :service_id => si.id
      Job.create! :name => "Responsable Décor",                     :responsible => true,  :service_id => deco.id
      Job.create! :name => "Graphiste Sénior",                      :responsible => false, :service_id => deco.id
      Job.create! :name => "Graphiste",                             :responsible => false, :service_id => deco.id
      Job.create! :name => "Poseur de film",                        :responsible => false, :service_id => deco.id
      Job.create! :name => "Responsable de Production",             :responsible => true,  :service_id => prod.id
      Job.create! :name => "Chef d'équipe Plasturgie",              :responsible => false, :service_id => prod.id
      Job.create! :name => "Monteur Câbleur",                       :responsible => false, :service_id => prod.id
      Job.create! :name => "Plasticien Monteur",                    :responsible => false, :service_id => prod.id
      Job.create! :name => "Chef d'équipe Métallier",               :responsible => false, :service_id => prod.id
      Job.create! :name => "Métallier",                             :responsible => false, :service_id => prod.id
      Job.create! :name => "Chaudronnier",                          :responsible => false, :service_id => prod.id
      Job.create! :name => "Dessinateur Fraiseur",                  :responsible => false, :service_id => prod.id
      Job.create! :name => "Peintre",                               :responsible => false, :service_id => prod.id
      Job.create! :name => "Chef d'équipe Pose",                    :responsible => false, :service_id => pose.id
      Job.create! :name => "Poseur d'enseignes",                    :responsible => false, :service_id => pose.id
      Job.create! :name => "Poseur",                                :responsible => false, :service_id => pose.id
      
      # default contact types
      ContactType.create! :name => "Normal",                  :owner => "Customer"
      ContactType.create! :name => "Contact de facturation",  :owner => "Customer"
      ContactType.create! :name => "Contact de livraison",    :owner => "Customer"
      
      ContactType.create! :name => "Normal",                  :owner => "Establishment"
      ContactType.create! :name => "Contact de facturation",  :owner => "Establishment"
      ContactType.create! :name => "Contact de livraison",    :owner => "Establishment"
      ContactType.create! :name => "Accueil",                 :owner => "Establishment"
      
      ContactType.create! :name => "Normal",                  :owner => "Supplier"
      
      ContactType.create! :name => "Normal",                  :owner => "Subcontractor"
      
      ContactType.create! :name => "Contact commercial",      :owner => "Order"
      ContactType.create! :name => "Contact sur site",        :owner => "Order"
      ContactType.create! :name => "Contact de facturation",  :owner => "Order"
      
      # default users and roles
      user_admin = User.create! :username => "admin", :password => "admin", :enabled => 1
      user_guest = User.create! :username => "guest", :password => "guest", :enabled => 1
      
      role_admin = Role.create! :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
      role_guest = Role.create! :name => "guest", :description => "Ce rôle permet un accés à toutes les ressources publiques en lecture seule" 
      
      user_admin.roles << role_admin
      user_guest.roles << role_guest

      # default activity sectors
      ActivitySector.create! :name => "Grande distribution"
      ActivitySector.create! :name => "Hôtellerie"
      ActivitySector.create! :name => "Téléphonie"
      
      # default third types
      private_third_type  = ThirdType.create! :name => "Privé"
      public_third_type   = ThirdType.create! :name => "Public"
      
      # default legal forms
      LegalForm.create! :name => "SARL",                      :third_type_id => private_third_type.id
      LegalForm.create! :name => "SA",                        :third_type_id => private_third_type.id
      LegalForm.create! :name => "SAS",                       :third_type_id => private_third_type.id
      LegalForm.create! :name => "EURL",                      :third_type_id => private_third_type.id
      LegalForm.create! :name => "Association",               :third_type_id => private_third_type.id
      LegalForm.create! :name => "Etat",                      :third_type_id => public_third_type.id
      LegalForm.create! :name => "Collectivité territoriale", :third_type_id => public_third_type.id
      
      # default payment methods
      PaymentMethod.create! :name => "Virement"
      PaymentMethod.create! :name => "Chèque"
      PaymentMethod.create! :name => "Espèce"
      PaymentMethod.create! :name => "Lettre de change"
      PaymentMethod.create! :name => "Billet à ordre"
      
      # default payment time limits
      PaymentTimeLimit.create! :name => "Comptant"
      PaymentTimeLimit.create! :name => "30 jours nets"
      PaymentTimeLimit.create! :name => "60 jours nets"
      
      # default measure units
      UnitMeasure.create! :name => "Millimètre",          :symbol => "mm"
      UnitMeasure.create! :name => "Centimètre",          :symbol => "cm"
      UnitMeasure.create! :name => "Décimètre",           :symbol => "dm"
      UnitMeasure.create! :name => "Mètre",               :symbol => "m"
      UnitMeasure.create! :name => "Millimètre carré",    :symbol => "mm²"
      UnitMeasure.create! :name => "Centimètretre carré", :symbol => "cm²"
      UnitMeasure.create! :name => "Décimètre carré",     :symbol => "dm²"
      UnitMeasure.create! :name => "Mètre carré",         :symbol => "m²"
      UnitMeasure.create! :name => "Millimètre cube",     :symbol => "mm³"
      UnitMeasure.create! :name => "Centimètretre cube",  :symbol => "cm³"
      UnitMeasure.create! :name => "Décimètre cube",      :symbol => "dm³"
      UnitMeasure.create! :name => "Mètre cube",          :symbol => "m³"
      UnitMeasure.create! :name => "Millilitre",          :symbol => "ml"
      UnitMeasure.create! :name => "Centilitre",          :symbol => "cl"
      UnitMeasure.create! :name => "Décilitre",           :symbol => "dl"
      UnitMeasure.create! :name => "Litre",               :symbol => "l"
      
      # default establishment types
      EstablishmentType.create! :name => "Siège social"
      EstablishmentType.create! :name => "Entrepôt"
      EstablishmentType.create! :name => "Atelier"
      EstablishmentType.create! :name => "Magasin"
      EstablishmentType.create! :name => "Station service"
      
      # default factors
      cga = Factor.create!(:name => "CGA", :fullname => "Compagnie Générale d'Affacturage")
      
      # default customers and establishements
      customer = Customer.new(:name => "Client par défaut", :siret_number => "12345678912345", :activity_sector_id => ActivitySector.first.id, :legal_form_id => LegalForm.first.id, 
        :payment_method_id => PaymentMethod.first.id, :payment_time_limit_id => PaymentTimeLimit.first.id, :activated => true)
      
      customer.build_bill_to_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment1 = customer.build_establishment(:name => "Mon Etablissement", :establishment_type_id => EstablishmentType.first.id)
      establishment2 = customer.build_establishment(:name => "Super Etablissement", :establishment_type_id => EstablishmentType.last.id)
      establishment1.build_address(:street_name => "2 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment2.build_address(:street_name => "3 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Marie", :zip_code => "97438")
      
      customer.save!
      
      # default contacts
      contact1 = Contact.create! :first_name => "Jean-Jacques", :last_name => "Dupont",   :contact_type_id => ContactType.first.id, :email => "jean-jacques@dupont.fr", :job => "Commercial", :gender => "M"
      contact2 = Contact.create! :first_name => "Pierre-Paul",  :last_name => "Dupond",   :contact_type_id => ContactType.first.id, :email => "pierre-paul@dupond.fr",  :job => "Commercial", :gender => "M"
      contact3 = Contact.create! :first_name => "Nicolas",      :last_name => "Hoareau",  :contact_type_id => ContactType.first.id, :email => "nicolas@hoarau.fr",      :job => "Commercial", :gender => "M"
      
      # create numbers and assign numbers to contacts
      contact1.numbers.build(:number => "692246801", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      contact2.numbers.build(:number => "262357913", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
      contact3.numbers.build(:number => "918729871", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      contact1.save!
      contact2.save!
      contact3.save!
      
      # default suppliers
      supplier1 = Supplier.create! :name => "Store Concept", :siret_number => "12345678912346", :activity_sector_id => ActivitySector.first.id, :legal_form_id => LegalForm.first.id
      supplier1.create_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      supplier1.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      supplier1.save!
      
      supplier2 = Supplier.create! :name => "Globo", :siret_number => "12345678912348", :activity_sector_id => ActivitySector.first.id, :legal_form_id => LegalForm.first.id
      supplier2.create_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      supplier2.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      supplier2.save!
      
      # assign contacts to establishments and suppliers
      establishment1.contacts << contact1
      establishment2.contacts << contact2
      supplier1.contacts << contact3
      
      # default subcontractors
      Subcontractor.create! :name => "Sous traitant par défaut", :siret_number => "12345678912345", :activity_sector_id => ActivitySector.first.id, :legal_form_id => LegalForm.first.id
      
      # default commodity categories
      metal = CommodityCategory.create! :name => "Metal"
      toles = CommodityCategory.create! :name => "Tôles", :commodity_category_id => metal.id, :unit_measure_id => UnitMeasure.first.id
      tubes = CommodityCategory.create! :name => "Tubes", :commodity_category_id => metal.id, :unit_measure_id => UnitMeasure.first.id
        
      # default VAT rates
      vat1 = Vat.create! :name => "19.6", :rate => "19.6"
      vat2 = Vat.create! :name => "8.5",  :rate => "8.5"
      vat3 = Vat.create! :name => "5.5",  :rate => "5.5"
      vat4 = Vat.create! :name => "2.1", :rate => "2.1"
      vat5 = Vat.create! :name => "Exo.", :rate => "0"
      
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
      reference111 = ProductReference.create! :name => "Reference 1.1.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 10, :production_time => 2, :delivery_cost_manpower => 20, :delivery_time => 3,   :reference => "XKTO89", :vat => vat1.rate
      reference112 = ProductReference.create! :name => "Reference 1.1.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 20, :production_time => 2, :delivery_cost_manpower => 10, :delivery_time => 1.5, :reference => "XKTO90", :vat => vat2.rate
      reference113 = ProductReference.create! :name => "Reference 1.1.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 30, :production_time => 3, :delivery_cost_manpower => 30, :delivery_time => 3,   :reference => "XKTO91", :vat => vat3.rate
     
      ProductReference.create! :name => "Reference 1.2.1", :description => "Description de la référence 1.2.1", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 10, :production_time => 2.7,  :delivery_cost_manpower => 30, :delivery_time => 2,   :reference => "XKTO92", :vat => vat4.rate
      ProductReference.create! :name => "Reference 1.2.2", :description => "Description de la référence 1.2.2", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 20, :production_time => 4,    :delivery_cost_manpower => 40, :delivery_time => 4,   :reference => "XKTO93", :vat => vat1.rate
      ProductReference.create! :name => "Reference 1.2.3", :description => "Description de la référence 1.2.3", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 30, :production_time => 4,    :delivery_cost_manpower => 20, :delivery_time => 2,   :reference => "XKTO94", :vat => vat2.rate
      ProductReference.create! :name => "Reference 1.3.1", :description => "Description de la référence 1.3.1", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 10, :production_time => 1,    :delivery_cost_manpower => 10, :delivery_time => 3.5, :reference => "XKTO95", :vat => vat2.rate
      ProductReference.create! :name => "Reference 1.3.2", :description => "Description de la référence 1.3.2", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 20, :production_time => 5,    :delivery_cost_manpower => 20, :delivery_time => 1,   :reference => "XKTO96", :vat => vat3.rate
      ProductReference.create! :name => "Reference 1.3.3", :description => "Description de la référence 1.3.3", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 30, :production_time => 2.9,  :delivery_cost_manpower => 10, :delivery_time => 2.3, :reference => "XKTO97", :vat => vat4.rate
      
      # default society activity sectors
      SocietyActivitySector.create! :name => "Enseigne"
      SocietyActivitySector.create! :name => "Signalétique"
      SocietyActivitySector.create! :name => "Routes"
      SocietyActivitySector.create! :name => "Usinage"
      
      ## default_mime_type
      jpg = MimeType.create!(:name => "image/jpeg")
      jpg.mime_type_extensions << MimeTypeExtension.create!(:name => "jpeg")
      jpg.mime_type_extensions << MimeTypeExtension.create!(:name => "jpe")
      jpg.mime_type_extensions << MimeTypeExtension.create!(:name => "jpg")
      gzip = MimeType.create!(:name => "application/x-gzip")
      gzip.mime_type_extensions << MimeTypeExtension.create!(:name => "gz")
      pdf = MimeType.create!(:name => "application/pdf")
      pdf.mime_type_extensions << MimeTypeExtension.create!(:name => "pdf")
      png = MimeType.create!(:name => "image/png")
      png.mime_type_extensions << MimeTypeExtension.create!(:name => "png")
      
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
      
      ## default document types (document types are created automatically when the class of the owner is parsed)
      # for customers
      d = DocumentType.find_or_create_by_name("graphic_charter")
      d.update_attribute(:title, "Charte graphique")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("logo")
      d.update_attribute(:title, "Logo")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("photo")
      d.update_attribute(:title, "Photo")
      d.mime_types << [ jpg, png ]
      
      # for equipments and equipment_interventions
      d = DocumentType.find_or_create_by_name("legal_paper")
      d.update_attribute(:title, "Document légal")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("invoice")
      d.update_attribute(:title, "Facture")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("expence_account")
      d.update_attribute(:title, "Note de frais")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("manual")
      d.update_attribute(:title, "Manuel")
      
      # for employees
      d = DocumentType.find_or_create_by_name("curriculum_vitae")
      d.update_attribute(:title, "Curriculum Vitae (CV)")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("driving_licence")
      d.update_attribute(:title, "Permis de conduire")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("identity_card")
      d.update_attribute(:title, "Pièce d'identité")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("other")
      d.update_attribute(:title, "Autre")
      d.mime_types << [ pdf, jpg, png ]
      
      # for job contract
      d = DocumentType.find_or_create_by_name("job_contract")
      d.update_attribute(:title, "Contrat de travail")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("job_contract_endorsement")
      d.update_attribute(:title, "Avenant au contrat de travail")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("resignation_letter")
      d.update_attribute(:title, "Lettre de licenciement")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("demission_letter")
      d.update_attribute(:title, "Lettre de démission")
      d.mime_types << [ pdf, jpg, png ]
      
      # for product in survey_step
      d = DocumentType.find_or_create_by_name("plan")
      d.update_attribute(:title, "Plan")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("mockup")
      d.update_attribute(:title, "Maquette")
      d.mime_types << [ pdf, jpg, png ]
      
      # for subcontractor_requests in survey_step
      d = DocumentType.find_or_create_by_name("quote")
      d.update_attribute(:title, "Devis")
      d.mime_types << [ pdf, jpg, png ]
      
      # create calendar for equipments
      Calendar.create! :name => "equipments_calendar", :title => "Planning des équipements"
      
      # default calendars and events
      calendar1 = Calendar.create! :user_id => user_admin.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
      calendar2 = Calendar.create! :user_id => user_guest.id, :name => "Calendrier par défaut de Guest", :color => "blue", :title => "Titre du calendrier"
      
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.day,  :end_at => DateTime.now + 1.day + 2.hours
      Event.create! :calendar_id => calendar2.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
      
      # default employees
      john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => dg.id, :civility_id => Civility.first.id, :family_situation_id => FamilySituation.first.id, :qualification => "Inconnu"
      john.numbers.build(:number => "692123456", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
      john.numbers.build(:number => "262987654", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
      john.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      john.build_iban(:bank_name => "Bred", :account_name => "John DOE" , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      john.save!
      john.jobs << Job.first
      john.user.roles << role_admin
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

      # Default order_type
      OrderType.create! :title => "Normal"
      OrderType.first.society_activity_sectors = SocietyActivitySector.find(:all)
      OrderType.create! :title => "SAV"
      OrderType.last.society_activity_sectors << SocietyActivitySector.first
      
      # default checklists
      checklist1 = Checklist.create! :name => "environment_checklist_for_products_in_survey_step", :title => "Checklist des contraintes de pose à la visite commerciale", :description => "Checklist à remplir pour chaque produit de la commande lors de la visite commerciale"
      acces = ChecklistOption.create! :checklist_id => checklist1.id, :title => "1- Accès"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Entrée"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Voie d'arrivée des véhicules"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Stationnement sous enseigne"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Hauteur"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Largeur"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => acces.id, :title => "Autre..."
      nrj = ChecklistOption.create! :checklist_id => checklist1.id, :title => "2- Sources d'énergie"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => nrj.id, :title => "Arrivée d'électricité"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => nrj.id, :title => "Arrivée d'électricité particulière"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => nrj.id, :title => "Air comprimé"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => nrj.id, :title => "Eau"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => nrj.id, :title => "Autre..."
      support = ChecklistOption.create! :checklist_id => checklist1.id, :title => "3- Support de pose"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Mur / Bloc"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Bardage"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Tôle"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Béton"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Bois"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Plâtre"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => support.id, :title => "Carrelage"
      lieu = ChecklistOption.create! :checklist_id => checklist1.id, :title => "4- Lieu de pose"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => lieu.id, :title => "Abrité"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => lieu.id, :title => "Extérieur"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => lieu.id, :title => "Intérieur"
      vehicule = ChecklistOption.create! :checklist_id => checklist1.id, :title => "5- Véhicule de pose"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => vehicule.id, :title => "Voiture particulier"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => vehicule.id, :title => "Voiture utilitaire"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => vehicule.id, :title => "Camion utilitaire"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => vehicule.id, :title => "Camion nacelle"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => vehicule.id, :title => "Camion 19 tonnes"
      equipments = ChecklistOption.create! :checklist_id => checklist1.id, :title => "6- Équipements particuliers"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => equipments.id, :title => "Groupe éléctrogène"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => equipments.id, :title => "Rallonge"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => equipments.id, :title => "Échaffaudage"
      ChecklistOption.create! :checklist_id => checklist1.id, :parent_id => equipments.id, :title => "Locations"
      
      # default send quote methods
      SendQuoteMethod.create!(:name => "Courrier")
      SendQuoteMethod.create!(:name => "E-mail")
      SendQuoteMethod.create!(:name => "Fax")
      
      # default send invoice methods
      SendInvoiceMethod.create!(:name => "Courrier")
      SendInvoiceMethod.create!(:name => "E-mail")
      SendInvoiceMethod.create!(:name => "Fax")
      
       # default document's sending methods
      DocumentSendingMethod.create!(:name => "Courrier")
      DocumentSendingMethod.create!(:name => "E-mail")
      DocumentSendingMethod.create!(:name => "Fax")
      
      # default dunning's sending methods
      DunningSendingMethod.create!(:name => "Téléphone")
      DunningSendingMethod.create!(:name => "E-mail")
      DunningSendingMethod.create!(:name => "Email + Téléphone")
      DunningSendingMethod.create!(:name => "Fax")
      DunningSendingMethod.create!(:name => "Téléphone + Fax")
      DunningSendingMethod.create!(:name => "Téléphone + E-mai + Fax")
      DunningSendingMethod.create!(:name => "Courrier")
      DunningSendingMethod.create!(:name => "Courrier + Accusé de réception")
      DunningSendingMethod.create!(:name => "Courrier + Accusé de réception + lettre de mise en demeurre")
      
      # default order form types
      OrderFormType.create!(:name => "Devis signé")
      OrderFormType.create!(:name => "Bon de commande")
      
      # default approachings
      Approaching.create!(:name => "E-mail")
      Approaching.create!(:name => "Téléphone")
      Approaching.create!(:name => "Fax")
      Approaching.create!(:name => "Courrier")
      Approaching.create!(:name => "Prospection")
      Approaching.create!(:name => "Visite client")
      
      # default orders
      order1 = Order.new(:title => "VISUEL NUMERIQUE GRAND FORMAT", :customer_needs => "1 visuel 10000 x 4000", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 10.days, :previsional_delivery => DateTime.now + 20.days)
      order1.build_bill_to_address(order1.customer.bill_to_address.attributes)
      order1.contacts << Customer.first.contacts.first
      establishment = order1.customer.establishments.first
      order1.ship_to_addresses.build(:establishment_id => establishment.id, :establishment_name => establishment.name, :should_create => 1).build_address(establishment.address.attributes)
      order1.save!
      
      order2 = Order.new(:title => "DRAPEAUX", :customer_needs => "4 drapeaux 400 x 700", :approaching_id => Approaching.first.id, :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :society_activity_sector_id => SocietyActivitySector.first.id, :order_type_id => OrderType.first.id, :quotation_deadline => DateTime.now + 5.days, :previsional_delivery => DateTime.now + 14.days)
      order2.build_bill_to_address(order2.customer.bill_to_address.attributes)
      order2.contacts << Customer.first.contacts.first
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
      quote.contacts << order1.contacts.first
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
      
      # default graphic unit measures
      GraphicUnitMeasure.create! :name => "Millimètre", :symbol => "mm"
      GraphicUnitMeasure.create! :name => "Centimètre", :symbol => "cm"
      GraphicUnitMeasure.create! :name => "Mètre",      :symbol => "m"
      
      # default mockup types
      MockupType.create! :name => "Vue d'ensemble"
      MockupType.create! :name => "Vue de face"
      MockupType.create! :name => "Vue de côté"
      MockupType.create! :name => "Vue de dessus"
      MockupType.create! :name => "Vue détaillée"
      
      # default graphic document types
      GraphicDocumentType.create! :name => "Vue d'ensemble"
      GraphicDocumentType.create! :name => "Vue de face"
      GraphicDocumentType.create! :name => "Vue de côté"
      GraphicDocumentType.create! :name => "Vue de dessus"
      GraphicDocumentType.create! :name => "Vue détaillée" 
      GraphicDocumentType.create! :name => "Récapitulatif de produits" 
      GraphicDocumentType.create! :name => "Fiche technique" 
      GraphicDocumentType.create! :name => "Ébauche commerciale"   
      
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
      
      #default delivery_note_types
      DeliveryNoteType.create! :title => "Livraison + Installation", :delivery => true,   :installation => true
      DeliveryNoteType.create! :title => "Livraison",                :delivery => true,   :installation => false
      DeliveryNoteType.create! :title => "Enlèvement Client",        :delivery => false,  :installation => false
      
      Vehicle.create! :service_id => prod.id, :job_id => Job.first.id, :employee_id => Employee.first.id, :supplier_id => Supplier.first.id, :name => "Ford Fiesta",    :serial_number => "123 ABC 974", :description => "Véhicule utilitaire",    :purchase_date => Date.today - 1.year, :purchase_price => "12000"
      Vehicle.create! :service_id => pose.id, :job_id => Job.last.id,  :employee_id => Employee.last.id,  :supplier_id => Supplier.last.id,  :name => "Renault Magnum", :serial_number => "456 DEF 974", :description => "Camion longue distance", :purchase_date => Date.today - 6.months, :purchase_price => "130000"
      
      %W{ BusinessObject Menu DocumentType Calendar }.each do |klass|
        klass.constantize.all.each do |object|
          object.permissions.each do |permission|
            permission.permissions_permission_methods.each do |object_permission|
              if permission.role == role_guest and ( object_permission.permission_method.name != "list" and object_permission.permission_method.name != "view" and object_permission.permission_method.name != "access" )
                object_permission.update_attribute(:active, false)
              else
                object_permission.update_attribute(:active, true)
              end
            end
          end
        end
      end
      
      # default invoice_types
      InvoiceType.create! :name => Invoice::DEPOSITE_INVOICE, :title => "Acompte",    :factorisable => false
      InvoiceType.create! :name => Invoice::STATUS_INVOICE,   :title => "Situation",  :factorisable => true
      InvoiceType.create! :name => Invoice::BALANCE_INVOICE,  :title => "Solde",      :factorisable => true
      InvoiceType.create! :name => Invoice::ASSET_INVOICE,    :title => "Avoir",      :factorisable => false
    end
    
    desc "Depopulate the database"
    task :depopulate => :environment do
      #[Role,User,Civility,FamilySituation,BusinessObjectPermission,MenuPermission,DocumentTypePermission,CalendarPermission,NumberType,Indicative,Job,JobContractType,
      #  JobContract,Service,EmployeeState,ThirdType,Employee,ContactType,Salary,Premium,Country,LegalForm,PaymentMethod,PaymentTimeLimit,
      #  UnitMeasure,EstablishmentType,Establishment,Supplier,Iban,Customer,Commodity,CommodityCategory,Product,ProductReference,ProductReferenceCategory,
      #  SocietyActivitySector,ActivitySector,DocumentType,FileType,MimeType,MimeTypeExtension,Calendar,Event,Employee,Number,Address,Contact,OrderType,Order,
      #  OrderTypesSocietyActivitySectors,SalesProcess,MemorandumsService,Memorandum, Checklist, ChecklistOption, Estimate, EstimatesProductReference, StepCommercial, StepSurvey, StepGraphicConception, StepEstimate, StepInvoicing].each do |model|
      #  
      #  puts "destroying all rows for model '#{model.name}'"
      #  model.destroy_all
      #end
    end
    
    #TODO find how to execute environment for each dependencies of the task reset, or to call explicitly the tasks with their environment
#    desc "Reset the database"
#    task :reset => [:depopulate, :populate]
    
    desc "Destroy all rows for all tables of the database"
    task :destroy_all => :environment do
      puts "TODO"
    end
  end
end

