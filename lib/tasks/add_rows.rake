namespace :osirails do
  namespace :db do
    desc "Populate the database"
    task :populate => :environment do
      # default civilities
      mr = Civility.create! :name => "Mr"
      Civility.create! :name => "Mme"
      Civility.create! :name => "Melle"
      
      # default family situations
      celib = FamilySituation.create! :name => "Célibataire"
      FamilySituation.create! :name => "Marié(e)"
      FamilySituation.create! :name => "Veuf/Veuve"
      FamilySituation.create! :name => "Divorcé(e)"
      FamilySituation.create! :name => "Pacsé(e)"
      
      # default number types
      mobile = NumberType.create! :name => "Mobile"
      fixe = NumberType.create! :name => "Fixe"
      NumberType.create! :name => "Fax"
      NumberType.create! :name => "Mobile Professionnel"
      NumberType.create! :name => "Fixe Professionnel"
      NumberType.create! :name => "Fax Professionnel"
      
      # default employee states
      titulaire = EmployeeState.create! :name => "Titulaire", :active => 1
      EmployeeState.create! :name => "Stagiaire", :active => 1
      EmployeeState.create! :name => "Licencié(e)", :active => 0
      EmployeeState.create! :name => "Démissionnaire", :active => 0
      
      # default job contract types
      cdi = JobContractType.create! :name => "CDI", :limited => 0
      JobContractType.create! :name => "CDD", :limited => 1
      
      # default leave types
      LeaveType.create! :name => "Congés payés"
      LeaveType.create! :name => "Congé maladie"
      LeaveType.create! :name => "Congé maternité"
      LeaveType.create! :name => "Congé paternité"
      LeaveType.create! :name => "Congés spéciaux"
      LeaveType.create! :name => "Récupération"
      
      # default countries
      france = Country.create! :name => "FRANCE", :code => "fr"
      reunion = Country.create! :name => "REUNION", :code => "fr"
      spain = Country.create! :name => "ESPAGNE", :code => "es"
      united_kingdom = Country.create! :name => "ANGLETERRE", :code => "gb"
      germany = Country.create! :name => "ALLEMAGNE", :code => "de"
      japan = Country.create! :name => "JAPON", :code => "jp"
      china = Country.create! :name => "CHINE", :code => "cn"
      united_states = Country.create! :name => "ETATS-UNIS", :code => "us"
      Country.create! :name => "CANADA", :code => "ca"
      
      # default indicatives
      indicative = Indicative.create! :indicative => "+262", :country_id => reunion.id
      Indicative.create! :indicative => "+33",:country_id=> france.id 
      Indicative.create! :indicative => "+34", :country_id => spain.id
      Indicative.create! :indicative => "+44", :country_id => united_kingdom.id
      Indicative.create! :indicative => "+49", :country_id => germany.id
      Indicative.create! :indicative => "+81", :country_id => japan.id
      Indicative.create! :indicative => "+86", :country_id => china.id
      Indicative.create! :indicative => "+1", :country_id => united_states.id
      
      # default cities
      City.create! :name => "BRAS PANON", :zip_code => "97412", :country_id => reunion.id
      City.create! :name => "CILAOS", :zip_code => "97413", :country_id => reunion.id
      City.create! :name => "ENTRE DEUX", :zip_code => "97414", :country_id => reunion.id
      City.create! :name => "ETANG SALE", :zip_code => "97427", :country_id => reunion.id
      City.create! :name => "LA CHALOUPE", :zip_code => "97416", :country_id => reunion.id
      City.create! :name => "LA MONTAGNE", :zip_code => "97417", :country_id => reunion.id
      City.create! :name => "LA NOUVELLE", :zip_code => "97428", :country_id => reunion.id
      City.create! :name => "LA PLAINE DES CAFRES", :zip_code => "97418", :country_id => reunion.id
      City.create! :name => "LA PLAINE DES PALMISTES", :zip_code => "97431", :country_id => reunion.id
      City.create! :name => "LA POSSESSION", :zip_code => "97419", :country_id => reunion.id
      City.create! :name => "LA RIVIERE", :zip_code => "97421", :country_id => reunion.id
      City.create! :name => "LA SALINE", :zip_code => "97422", :country_id => reunion.id
      City.create! :name => "LE GUILLAUME", :zip_code => "97423", :country_id => reunion.id
      City.create! :name => "LE PITON ST LEU", :zip_code => "97424", :country_id => reunion.id
      City.create! :name => "LE PORT", :zip_code => "97420", :country_id => reunion.id
      City.create! :name => "LE TAMPON", :zip_code => "97430", :country_id => reunion.id
      City.create! :name => "LES AVIRONS", :zip_code => "97425", :country_id => reunion.id
      City.create! :name => "LES TROIS BASSINS", :zip_code => "97426", :country_id => reunion.id
      City.create! :name => "PETITE ILE", :zip_code => "97429", :country_id => reunion.id
      City.create! :name => "PLATEAU CAILLOUX", :zip_code => "97460", :country_id => reunion.id
      City.create! :name => "RAVINE DES CABRIS", :zip_code => "97432", :country_id => reunion.id
      City.create! :name => "SALAZIE", :zip_code => "97433", :country_id => reunion.id
      City.create! :name => "SAINT ANDRE", :zip_code => "97440", :country_id => reunion.id
      City.create! :name => "SAINT BENOIT", :zip_code => "97470", :country_id => reunion.id
      City.create! :name => "SAINT DENIS", :zip_code => "97400", :country_id => reunion.id
      City.create! :name => "SAINT GILLES LES BAINS", :zip_code => "97434", :country_id => reunion.id
      City.create! :name => "SAINT GILLES LES HAUTS", :zip_code => "97435", :country_id => reunion.id
      City.create! :name => "SAINT JOSEPH", :zip_code => "97480", :country_id => reunion.id
      City.create! :name => "SAINT LEU", :zip_code => "97436", :country_id => reunion.id
      City.create! :name => "SAINT LOUIS", :zip_code => "97450", :country_id => reunion.id
      City.create! :name => "SAINT PAUL", :zip_code => "97411", :country_id => reunion.id
      City.create! :name => "SAINT PHILIPPE", :zip_code => "97442", :country_id => reunion.id
      City.create! :name => "SAINT PIERRE", :zip_code => "97410", :country_id => reunion.id
      City.create! :name => "SAINTE ANNE", :zip_code => "97437", :country_id => reunion.id
      City.create! :name => "SAINTE CLOTILDE", :zip_code => "97490", :country_id => reunion.id
      City.create! :name => "SAINTE MARIE", :zip_code => "97438", :country_id => reunion.id
      City.create! :name => "SAINTE ROSE", :zip_code => "97439", :country_id => reunion.id
      City.create! :name => "SAINTE SUZANNE", :zip_code => "97441", :country_id => reunion.id
      
      # default services
      dg   = Service.create! :name => "Direction Générale"
      af   = Service.create! :name => "Administratif et Financier",  :service_parent_id => dg.id
      com  = Service.create! :name => "Commercial",                  :service_parent_id => dg.id
      av   = Service.create! :name => "Achats/Ventes",               :service_parent_id => dg.id
      si   = Service.create! :name => "Informatique",                :service_parent_id => dg.id
      cg   = Service.create! :name => "Décor",                       :service_parent_id => dg.id
      prod = Service.create! :name => "Production",                  :service_parent_id => dg.id
      pose = Service.create! :name => "Pose",                        :service_parent_id => dg.id
      
      # default jobs
      Job.create! :name => "Directeur Général",                      :responsible => true,  :service_id => dg.id
      Job.create! :name => "Directeur Commercial",                   :responsible => true,  :service_id => com.id
      Job.create! :name => "Commercial",                             :responsible => false, :service_id => com.id
      Job.create! :name => "Chargé d'affaires",                      :responsible => false, :service_id => com.id
      Job.create! :name => "Directeur Administratif et Financier",   :responsible => true,  :service_id => af.id
      Job.create! :name => "Secrétaire",                             :responsible => false, :service_id => af.id
      Job.create! :name => "Assistante de Direction",                :responsible => false, :service_id => af.id
      Job.create! :name => "Comptable",                              :responsible => false, :service_id => af.id
      Job.create! :name => "Assistante des Ressources Humaines",     :responsible => false, :service_id => af.id
      Job.create! :name => "Responsable des Achats/Ventes",          :responsible => true,  :service_id => av.id
      Job.create! :name => "Assistante des Achats/Ventes",           :responsible => false, :service_id => av.id
      Job.create! :name => "Ingénieur Informaticien",                :responsible => true,  :service_id => si.id
      Job.create! :name => "Responsable Décor",                      :responsible => true,  :service_id => cg.id
      Job.create! :name => "Graphiste Sénior",                       :responsible => false, :service_id => cg.id
      Job.create! :name => "Graphiste",                              :responsible => false, :service_id => cg.id
      Job.create! :name => "Poseur de film",                         :responsible => false, :service_id => cg.id
      Job.create! :name => "Responsable de Production",              :responsible => true,  :service_id => prod.id
      Job.create! :name => "Chef d'équipe Plasturgie",               :responsible => false, :service_id => prod.id
      Job.create! :name => "Monteur Câbleur",                        :responsible => false, :service_id => prod.id
      Job.create! :name => "Plasticien Monteur",                     :responsible => false, :service_id => prod.id
      Job.create! :name => "Chef d'équipe Métallier",                :responsible => false, :service_id => prod.id
      Job.create! :name => "Métallier",                              :responsible => false, :service_id => prod.id
      Job.create! :name => "Chaudronnier",                           :responsible => false, :service_id => prod.id
      Job.create! :name => "Dessinateur Fraiseur",                   :responsible => false, :service_id => prod.id
      Job.create! :name => "Peintre",                                :responsible => false, :service_id => prod.id
      Job.create! :name => "Chef d'équipe Pose",                     :responsible => false, :service_id => pose.id
      Job.create! :name => "Poseur d'enseignes",                     :responsible => false, :service_id => pose.id
      Job.create! :name => "Poseur",                                 :responsible => false, :service_id => pose.id
      
      # default contact types
      contact_type1 = ContactType.create! :name => "Normal",  :owner => "Establishment"
      ContactType.create! :name => "Contact de livraison",    :owner => "Establishment"
      ContactType.create! :name => "Contact de facturation",  :owner => "Establishment"
      ContactType.create! :name => "Accueil",                 :owner => "Establishment"
      
      contact_type2 = ContactType.create! :name => "Normal",  :owner => "Supplier"
      
      ContactType.create! :name => "Normal",                  :owner => "Subcontractor"
      
      ContactType.create! :name => "Contact commercial",      :owner => "Order"
      ContactType.create! :name => "Contact sur site",        :owner => "Order"
      ContactType.create! :name => "Contact de facturation",  :owner => "Order"
      
      # default users and roles
      user_admin = User.create! :username => "admin" ,:password => "admin", :enabled => 1
      user_guest = User.create! :username => "guest",:password => "guest", :enabled => 1
      role_admin = Role.create! :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
      role_guest = Role.create! :name => "guest", :description => "Ce rôle permet un accés à toutes les ressources publiques en lecture seule" 
      user_admin.roles << role_admin
      user_guest.roles << role_guest
      
      # default activity sectors
      distribution = ActivitySector.create! :name => "Grande distribution"
      ActivitySector.create! :name => "Hôtellerie"
      ActivitySector.create! :name => "Téléphonie"
      
      # default third types
      private_third_type = ThirdType.create! :name => "Privé"
      public_third_type = ThirdType.create! :name => "Public"
      
      # default legal forms
      sarl = LegalForm.create! :name => "SARL", :third_type_id => private_third_type.id
      LegalForm.create! :name => "SA", :third_type_id => private_third_type.id
      LegalForm.create! :name => "SAS", :third_type_id => private_third_type.id
      LegalForm.create! :name => "EURL", :third_type_id => private_third_type.id
      LegalForm.create! :name => "Association", :third_type_id => private_third_type.id
      LegalForm.create! :name => "Etat", :third_type_id => public_third_type.id
      LegalForm.create! :name => "Collectivité territoriale", :third_type_id => public_third_type.id
      
      # default payment methods
      virement = PaymentMethod.create! :name => "Virement"
      PaymentMethod.create! :name => "Chèque"
      PaymentMethod.create! :name => "Espèce"
      PaymentMethod.create! :name => "Lettre de change"
      PaymentMethod.create! :name => "Billet à ordre"
      
      # default payment time limits
      comptant = PaymentTimeLimit.create! :name => "Comptant"
      PaymentTimeLimit.create! :name => "30 jours nets"
      PaymentTimeLimit.create! :name => "60 jours nets"
      
      # default measure units
      UnitMeasure.create! :name => "Millimètre", :symbol => "mm"
      UnitMeasure.create! :name => "Centimètre", :symbol => "cm"
      UnitMeasure.create! :name => "Décimètre", :symbol => "dm"
      UnitMeasure.create! :name => "Mètre", :symbol => "m"
      UnitMeasure.create! :name => "Millimètre carré", :symbol => "mm²"
      UnitMeasure.create! :name => "Centimètretre carré", :symbol => "cm²"
      UnitMeasure.create! :name => "Décimètre carré", :symbol => "dm²"
      metre_carre = UnitMeasure.create! :name => "Mètre carré", :symbol => "m²"
      UnitMeasure.create! :name => "Millimètre cube", :symbol => "mm³"
      UnitMeasure.create! :name => "Centimètretre cube", :symbol => "cm³"
      UnitMeasure.create! :name => "Décimètre cube", :symbol => "dm³"
      UnitMeasure.create! :name => "Mètre cube", :symbol => "m³"
      UnitMeasure.create! :name => "Millilitre", :symbol => "ml"
      UnitMeasure.create! :name => "Centilitre", :symbol => "cl"
      UnitMeasure.create! :name => "Décilitre", :symbol => "dl"
      UnitMeasure.create! :name => "Litre", :symbol => "l"
      
      # default establishment types
      siege     = EstablishmentType.create! :name => "Siège social"
      entrepot  = EstablishmentType.create! :name => "Entrepôt"
      atelier   = EstablishmentType.create! :name => "Atelier"
      magasin   = EstablishmentType.create! :name => "Magasin"
      station   = EstablishmentType.create! :name => "Station service"
      
      # default customers and establishements
      customer = Customer.new(:name => "Client par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id, 
        :payment_method_id => virement.id, :payment_time_limit_id => comptant.id, :activated => true)
      
      customer.build_bill_to_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment1 = customer.build_establishment(:name => "Mon Etablissement", :establishment_type_id => siege.id)
      establishment2 = customer.build_establishment(:name => "Super Etablissement", :establishment_type_id => magasin.id)
      establishment1.build_address(:street_name => "2 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment2.build_address(:street_name => "3 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Marie", :zip_code => "97438")
      
      customer.save!
      
      # default contacts
      contact1 = Contact.create! :first_name => "Jean-Jacques", :last_name => "Dupont",   :contact_type_id => contact_type1.id, :email => "jean-jacques@dupont.fr", :job => "Commercial", :gender => "M"
      contact2 = Contact.create! :first_name => "Pierre-Paul",  :last_name => "Dupond",   :contact_type_id => contact_type1.id, :email => "pierre-paul@dupond.fr",  :job => "Commercial", :gender => "M"
      contact3 = Contact.create! :first_name => "Nicolas",      :last_name => "Hoareau",  :contact_type_id => contact_type2.id, :email => "nicolas@hoarau.fr",      :job => "Commercial", :gender => "M"
      
      # create numbers and assign numbers to contacts
      contact1.numbers.build(:number => "692246801", :indicative_id => indicative.id, :number_type_id => mobile.id)
      contact2.numbers.build(:number => "262357913", :indicative_id => indicative.id, :number_type_id => fixe.id)
      contact3.numbers.build(:number => "918729871", :indicative_id => indicative.id, :number_type_id => mobile.id)
      contact1.save!
      contact2.save!
      contact3.save!
      
      # default suppliers
      #iban = Iban.create! :bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12"
      supplier = Supplier.create! :name => "Fournisseur par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id
      supplier.create_address(:street_name => "1 rue des palmiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      #supplier.iban = iban
      supplier.build_iban(:bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      supplier.save!
      
      # assign contacts to establishments and suppliers
      establishment1.contacts << contact1
      establishment2.contacts << contact2
      supplier.contacts << contact3
      
      # default subcontractors
      Subcontractor.create(:name => "Sous traitant par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id)
      
      # default commodity categories
      metal = CommodityCategory.create! :name => "Metal"
      toles = CommodityCategory.create! :name => "Tôles", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id
      tubes = CommodityCategory.create! :name => "Tubes", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id
      
      # default commodities
      Commodity.create! :name => "Galva 1500x3000x2", :fob_unit_price => "26.88", :taxe_coefficient => "0", :measure => "4.50", :unit_mass => "70.65",
        :commodity_category_id => toles.id, :supplier_id => supplier.id
      Commodity.create! :name => "Galva 1500x3000x3", :fob_unit_price => "45.12", :taxe_coefficient => "0", :measure => "4.50", :unit_mass => "105.98",
        :commodity_category_id => toles.id, :supplier_id => supplier.id
      Commodity.create! :name => "Galva rond Ø20x2 Lg 6m", :fob_unit_price => "1.63", :taxe_coefficient => "0", :measure => "6", :unit_mass => "5.32",
        :commodity_category_id => tubes.id, :supplier_id => supplier.id
        
      # default VAT rates
      vat1 = Vat.create!(:name => "19.6", :rate => "19.6")
      vat2 = Vat.create!(:name => "8.5", :rate => "8.5")
      vat3 = Vat.create!(:name => "5.5", :rate => "5.5")
      vat4 = Vat.create!(:name => "Exo.", :rate => "0")
      
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
      
      ## default file types
      # for feature
#      f = FileType.create! :name => "Archive de feature", :model_owner => "Feature"
#      f.mime_types << MimeType.find_by_name("application/x-gzip")
      # for employees
#      f = FileType.create! :name => "CV", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f = FileType.create! :name => "Lettre de motivation", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f = FileType.create! :name => "Contrat de travail", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
      # for step survey
#      f = FileType.create! :name => "Photo Survey", :model_owner => "StepSurvey"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("image/png")
      # for step graphic conception
#      f = FileType.create! :name => "Maquette", :model_owner => "StepGraphicConception"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create! :name => "Plan de conception", :model_owner => "StepGraphicConception"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
      # for press proof
#      f = FileType.create! :name => "PressProof", :model_owner => "PressProof"
#      f.mime_types << MimeType.find_by_name("image/png")
#      FileType.create! :name => "Devis", :model_owner => "Dossier"
#      FileType.create! :name => "Facture", :model_owner => "Dossier"
      # for customers
#      f = FileType.create! :name => "Charte graphique", :model_owner => "Customer"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create! :name => "Plan de fabrication", :model_owner => "Customer"
#      f.mime_types << MimeType.find_by_name("application/pdf")
      # for job_contracts
#      f = FileType.create! :name => "Contrat de travail", :model_owner => "JobContract"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create! :name => "Avenant au contrat", :model_owner => "JobContract"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
      
      # default calendars and events
      calendar1 = Calendar.create! :user_id => user_admin.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
      Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.days, :end_at => DateTime.now + 1.days + 2.hours
      calendar2 = Calendar.create! :user_id => user_guest.id, :name => "Calendrier par défaut de Guest", :color => "blue", :title => "Titre du calendrier"
      Event.create! :calendar_id => calendar2.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
      
      # default employees
      john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => dg.id, :civility_id => mr.id, :family_situation_id => celib.id, :qualification => "Inconnu"
      john.numbers.build(:number => "692123456", :indicative_id => indicative.id, :number_type_id => mobile.id)
      john.numbers.build(:number => "262987654", :indicative_id => indicative.id, :number_type_id => fixe.id)
      john.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      john.build_iban(:bank_name => "Bred", :account_name => "John DOE" , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
      john.save!
      john.jobs << Job.first
      john.user.roles << role_admin
      john.user.enabled = true
      john.user.save!
      john.job_contract.update_attributes(:start_date => Date.today, :end_date => Date.today + 1.years, :job_contract_type_id => cdi.id, :employee_state_id => titulaire.id, :salary => "2000")
      
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
      m1 = Memorandum.create! :title => 'Note de service 1', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.months
      m2 = Memorandum.create! :title => 'Note de service 2', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.months
      m3 = Memorandum.create! :title => 'Note de service 3', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.months
      m4 = Memorandum.create! :title => 'Note de service 4', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.weeks
      m5 = Memorandum.create! :title => 'Note de service 5', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.weeks
      m6 = Memorandum.create! :title => 'Note de service 6', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.weeks
      m7 = Memorandum.create! :title => 'Note de service 7', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.days
      m8 = Memorandum.create! :title => 'Note de service 8', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.days
      m9 = Memorandum.create! :title => 'Note de service 9', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.days
      m10 = Memorandum.create! :title => 'Note de service 10', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.hours
      m11 = Memorandum.create! :title => 'Note de service 11', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.hours
      m12 = Memorandum.create! :title => 'Note de service 12', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now
      
      m1.services << Service.first
      m2.services << Service.first
      m3.services << Service.first
      m4.services << Service.first
      m5.services << Service.first
      m6.services << Service.first
      m7.services << Service.first
      m8.services << Service.first
      m9.services << Service.first
      m10.services << Service.first
      m11.services << Service.first
      m12.services << Service.first
      
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
      
      ## default checklist 
      #Checklist.create! :name => "Livraison sur site", :step_id => survey_step = Step.find_by_name("survey_step").id
      #Checklist.create! :name => "Accès voiture", :step_id => survey_step
      #c = Checklist.create! :name => "Frais de déplacement", :step_id => survey_step
      #c.checklist_options << ChecklistOption.create!(:name => "< 10 km")
      #c.checklist_options << ChecklistOption.create!(:name => "< 50 km")
      #c.checklist_options << ChecklistOption.create!(:name => "< 80 km")
      #
      #Checklist.create! :name => "Question 1", :step_id => graphic_concetion_step = Step.find_by_name("graphic_conception_step").id
      #Checklist.create! :name => "Question numéro 2", :step_id => graphic_concetion_step
      #c = Checklist.create! :name => "Question numéro 123", :step_id => graphic_concetion_step
      #c.checklist_options << ChecklistOption.create!(:name => "Option 1")
      #c.checklist_options << ChecklistOption.create!(:name => "Option 2")
      #c.checklist_options << ChecklistOption.create!(:name => "Option 3")
      
      # default send quote methods
      SendQuoteMethod.create!(:name => "Courrier")
      SendQuoteMethod.create!(:name => "E-mail")
      SendQuoteMethod.create!(:name => "Fax")
      
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
      Product.create! :reference => "01010101", :name => "Produit 1.1.1.1", :description => "Description du produit 1.1.1.1", :product_reference_id => reference111.id, :dimensions => "1000x2000", :quantity => 1, :order_id => order1.id
      Product.create! :reference => "01010201", :name => "Produit 1.1.2.1", :description => "Description du produit 1.1.2.1", :product_reference_id => reference112.id, :dimensions => "1000x3000", :quantity => 2, :order_id => order1.id
      Product.create! :reference => "01010301", :name => "Produit 1.1.3.1", :description => "Description du produit 1.1.3.1", :product_reference_id => reference113.id, :dimensions => "2000x4000", :quantity => 3, :order_id => order1.id
      Product.create! :reference => "01010202", :name => "Produit 1.1.2.2", :description => "Description du produit 1.1.2.2", :product_reference_id => reference111.id, :dimensions => "2000x2000", :quantity => 1, :order_id => order2.id
      Product.create! :reference => "01010302", :name => "Produit 1.1.3.2", :description => "Description du produit 1.1.3.2", :product_reference_id => reference112.id, :dimensions => "2000x5000", :quantity => 2, :order_id => order2.id
      Product.create! :reference => "01010303", :name => "Produit 1.1.3.3", :description => "Description du produit 1.1.3.3", :product_reference_id => reference113.id, :dimensions => "5000x1000", :quantity => 3, :order_id => order2.id
      
      # default graphic unit measures
      GraphicUnitMeasure.create! :name => "Millimètre", :symbol => "mm"
      GraphicUnitMeasure.create! :name => "Centimètre", :symbol => "cm"
      GraphicUnitMeasure.create! :name => "Mètre", :symbol => "m"
      
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
      mockup = Order.first.mockups.build(:name => "Sample", 
                                         :description => "Sample de maquette par défaut", 
                                         :graphic_unit_measure => GraphicUnitMeasure.first, 
                                         :creator => Employee.first, 
                                         :mockup_type => MockupType.first, 
                                         :product => Order.first.products.first,
                                         :graphic_item_version_attributes => {:image => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") )}
                                        )      
      mockup.save!
      
      mockup.graphic_item_version_attributes = {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
                                                :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") )}      
      mockup.save!
      
      other_mockup = Order.first.mockups.build(:name => "Sample 2", 
                                               :description => "Sample 2 de maquette par défaut", 
                                               :graphic_unit_measure => GraphicUnitMeasure.last, 
                                               :creator => Employee.last, 
                                               :mockup_type => MockupType.last, 
                                               :product => Order.first.products.last,
                                               :graphic_item_version_attributes => {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "another_graphic_item.jpg") ),
                                                                                    :source => File.new( File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf") )} )      
      other_mockup.save!
      
      other_mockup.graphic_item_version_attributes = {:image  => File.new( File.join(RAILS_ROOT, "test", "fixtures", "graphic_item.jpg") )}    
      other_mockup.save!
      
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
