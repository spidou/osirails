namespace :osirails do
  namespace :db do
    desc "Populate the database"
    task :populate => :environment do
      # default civilities
      mr = Civility.create :name => "Mr"
      Civility.create :name => "Mme"
      Civility.create :name => "Mademoiselle"

      # default family situations
      celib = FamilySituation.create :name => "Célibataire"
      FamilySituation.create :name => "Marié(e)"
      FamilySituation.create :name => "Veuf/Veuve"
      FamilySituation.create :name => "Divorcé(e)"

      # default number types
      mobile = NumberType.create :name => "Mobile"
      fixe = NumberType.create :name => "Fixe"
      NumberType.create :name => "Fax"
      NumberType.create :name => "Mobile Professionnel"
      NumberType.create :name => "Fixe Professionnel"
      NumberType.create :name => "Fax Professionnel"

      # default employee states
      titulaire = EmployeeState.create :name => "Titulaire", :active => 1
      EmployeeState.create :name => "Stagiaire", :active => 1
      EmployeeState.create :name => "Licencié(e)", :active => 0
      EmployeeState.create :name => "Démissionnaire", :active => 0

      # default job contract types
      cdi = JobContractType.create :name => "CDI", :limited => 0
      JobContractType.create :name => "CDD", :limited => 1
      
      # default leave types
      LeaveType.create :name => "Congés payés"
      LeaveType.create :name => "Congé maladie"
      LeaveType.create :name => "Congé maternité"
      LeaveType.create :name => "Congé paternité"
      LeaveType.create :name => "Congés spéciaux"
      LeaveType.create :name => "Récupération"
      
      # default countries
      france = Country.create :name => "FRANCE", :code => "fr"
      reunion = Country.create :name => "REUNION", :code => "fr"
      spain = Country.create :name => "ESPAGNE", :code => "es"
      united_kingdom = Country.create :name => "ANGLETERRE", :code => "gb"
      germany = Country.create :name => "ALLEMAGNE", :code => "de"
      japan = Country.create :name => "JAPON", :code => "jp"
      china = Country.create :name => "CHINE", :code => "cn"
      united_states = Country.create :name => "ETATS-UNIS", :code => "us"
      Country.create :name => "CANADA", :code => "ca"

      # default indicatives
      indicative = Indicative.create :indicative => "+262", :country_id => reunion.id
      Indicative.create :indicative => "+33",:country_id=> france.id
      Indicative.create :indicative => "+34", :country_id => spain.id
      Indicative.create :indicative => "+44", :country_id => united_kingdom.id
      Indicative.create :indicative => "+49", :country_id => germany.id
      Indicative.create :indicative => "+81", :country_id => japan.id
      Indicative.create :indicative => "+86", :country_id => china.id
      Indicative.create :indicative => "+1", :country_id => united_states.id

      # default cities
      City.create :name => "BRAS PANON", :zip_code => "97412", :country_id => reunion.id
      City.create :name => "CILAOS", :zip_code => "97413", :country_id => reunion.id
      City.create :name => "ENTRE DEUX", :zip_code => "97414", :country_id => reunion.id
      City.create :name => "ETANG SALE", :zip_code => "97427", :country_id => reunion.id
      City.create :name => "LA CHALOUPE", :zip_code => "97416", :country_id => reunion.id
      City.create :name => "LA MONTAGNE", :zip_code => "97417", :country_id => reunion.id
      City.create :name => "LA NOUVELLE", :zip_code => "97428", :country_id => reunion.id
      City.create :name => "LA PLAINE DES CAFRES", :zip_code => "97418", :country_id => reunion.id
      City.create :name => "LA PLAINE DES PALMISTES", :zip_code => "97431", :country_id => reunion.id
      City.create :name => "LA POSSESSION", :zip_code => "97419", :country_id => reunion.id
      City.create :name => "LA RIVIERE", :zip_code => "97421", :country_id => reunion.id
      City.create :name => "LA SALINE", :zip_code => "97422", :country_id => reunion.id
      City.create :name => "LE GUILLAUME", :zip_code => "97423", :country_id => reunion.id
      City.create :name => "LE PITON ST LEU", :zip_code => "97424", :country_id => reunion.id
      City.create :name => "LE PORT", :zip_code => "97420", :country_id => reunion.id
      City.create :name => "LE TAMPON", :zip_code => "97430", :country_id => reunion.id
      City.create :name => "LES AVIRONS", :zip_code => "97425", :country_id => reunion.id
      City.create :name => "LES TROIS BASSINS", :zip_code => "97426", :country_id => reunion.id
      City.create :name => "PETITE ILE", :zip_code => "97429", :country_id => reunion.id
      City.create :name => "PLATEAU CAILLOUX", :zip_code => "97460", :country_id => reunion.id
      City.create :name => "RAVINE DES CABRIS", :zip_code => "97432", :country_id => reunion.id
      City.create :name => "SALAZIE", :zip_code => "97433", :country_id => reunion.id
      City.create :name => "SAINT ANDRE", :zip_code => "97440", :country_id => reunion.id
      City.create :name => "SAINT BENOIT", :zip_code => "97470", :country_id => reunion.id
      City.create :name => "SAINT DENIS", :zip_code => "97400", :country_id => reunion.id
      City.create :name => "SAINT GILLES LES BAINS", :zip_code => "97434", :country_id => reunion.id
      City.create :name => "SAINT GILLES LES HAUTS", :zip_code => "97435", :country_id => reunion.id
      City.create :name => "SAINT JOSEPH", :zip_code => "97480", :country_id => reunion.id
      City.create :name => "SAINT LEU", :zip_code => "97436", :country_id => reunion.id
      City.create :name => "SAINT LOUIS", :zip_code => "97450", :country_id => reunion.id
      City.create :name => "SAINT PAUL", :zip_code => "97411", :country_id => reunion.id
      City.create :name => "SAINT PHILIPPE", :zip_code => "97442", :country_id => reunion.id
      City.create :name => "SAINT PIERRE", :zip_code => "97410", :country_id => reunion.id
      City.create :name => "SAINTE ANNE", :zip_code => "97437", :country_id => reunion.id
      City.create :name => "SAINTE CLOTILDE", :zip_code => "97490", :country_id => reunion.id
      City.create :name => "SAINTE MARIE", :zip_code => "97438", :country_id => reunion.id
      City.create :name => "SAINTE ROSE", :zip_code => "97439", :country_id => reunion.id
      City.create :name => "SAINTE SUZANNE", :zip_code => "97441", :country_id => reunion.id

      # default services
      dg = Service.create :name => "Direction Générale"
      af = Service.create :name => "Administratif et Financier", :service_parent_id => dg.id
      com = Service.create :name => "Commercial", :service_parent_id => dg.id
      av = Service.create :name => "Achats/Ventes", :service_parent_id => dg.id
      si = Service.create :name => "Informatique", :service_parent_id => dg.id
      cg = Service.create :name => "Conception Graphique", :service_parent_id => dg.id
      prod = Service.create :name => "Production", :service_parent_id => dg.id
      Service.create :name => "Atelier Décor", :service_parent_id => prod.id
      Service.create :name => "Atelier Découpe", :service_parent_id => prod.id
      Service.create :name => "Atelier Fraisage", :service_parent_id => prod.id

      pose = Service.create :name => "Pose", :service_parent_id => dg.id
      
      # default jobs
      Job.create :name => "Directeur Général", :responsible => true, :service_id => dg.id
      Job.create :name => "Directeur Commercial", :responsible => true, :service_id => com.id
      Job.create :name => "Commercial", :responsible => false, :service_id => com.id
      Job.create :name => "Chargé d'affaires", :responsible => false, :service_id => com.id
      Job.create :name => "Directeur Administratif et Financier", :responsible => true, :service_id => af.id
      Job.create :name => "Secrétaire", :responsible => false, :service_id => af.id
      Job.create :name => "Assistante de Direction", :responsible => false, :service_id => af.id
      Job.create :name => "Comptable", :responsible => false, :service_id => af.id
      Job.create :name => "Assistante des Ressources Humaines", :responsible => false, :service_id => af.id
      Job.create :name => "Responsable des Achats/Ventes", :responsible => true, :service_id => av.id
      Job.create :name => "Assistante des Achats/Ventes", :responsible => false, :service_id => av.id
      Job.create :name => "Ingénieur Informaticien", :responsible => true, :service_id => si.id
      Job.create :name => "Responsable Conception Graphique", :responsible => true, :service_id => cg.id
      Job.create :name => "Graphiste Sénior", :responsible => false, :service_id => cg.id
      Job.create :name => "Graphiste", :responsible => false, :service_id => cg.id
      Job.create :name => "Poseur de film", :responsible => false, :service_id => cg.id
      Job.create :name => "Responsable de Production", :responsible => true, :service_id => prod.id
      Job.create :name => "Chef d'équipe Plasturgie", :responsible => false, :service_id => prod.id
      Job.create :name => "Monteur Câbleur", :responsible => false, :service_id => prod.id
      Job.create :name => "Plasticien Monteur", :responsible => false, :service_id => prod.id
      Job.create :name => "Chef d'équipe Métallier", :responsible => false, :service_id => prod.id
      Job.create :name => "Métallier", :responsible => false, :service_id => prod.id
      Job.create :name => "Chaudronnier", :responsible => false, :service_id => prod.id
      Job.create :name => "Dessinateur Fraiseur", :responsible => false, :service_id => prod.id
      Job.create :name => "Peintre", :responsible => false, :service_id => prod.id
      Job.create :name => "Chef d'équipe Pose", :responsible => false, :service_id => pose.id
      Job.create :name => "Poseur d'enseignes", :responsible => false, :service_id => pose.id
      Job.create :name => "Poseur", :responsible => false, :service_id => pose.id
      
      # default contact types
      contact_customer1 = ContactType.create :name => "Normal", :owner => "Customer"
      contact_customer2 = ContactType.create :name => "Contact de facturation", :owner => "Customer"
      contact_customer3 = ContactType.create :name => "Contact de livraison", :owner => "Customer"
      contact_establishment1 = ContactType.create :name => "Normal", :owner => "Establishment"
      contact_establishment2 = ContactType.create :name => "Contact de livraison", :owner => "Establishment"
      contact_establishment3 = ContactType.create :name => "Acceuill", :owner => "Establishment"
      contact_supplier1 = ContactType.create :name => "Normal", :owner => "Supplier"

      # default users and roles
      user_admin = User.create :username => "admin" ,:password => "admin", :enabled => 1
      user_guest = User.create :username => "guest",:password => "guest", :enabled => 1
      role_admin = Role.create  :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
      role_guest = Role.create  :name => "guest" ,:description => "Ce rôle permet un accés à toutes les ressources publiques en lecture seule"
      user_admin.roles << role_admin
      user_guest.roles << role_guest

      # default activity sectors
      distribution = ActivitySector.create :name => "Grande distribution"
      ActivitySector.create :name => "Hôtellerie"
      ActivitySector.create :name => "Téléphonie"

      # default third types
      private = ThirdType.create :name => "Privé"
      public = ThirdType.create :name => "Public"

      # default legal forms
      sarl = LegalForm.create :name => "SARL", :third_type_id => private.id
      LegalForm.create :name => "SA", :third_type_id => private.id
      LegalForm.create :name => "SAS", :third_type_id => private.id
      LegalForm.create :name => "EURL", :third_type_id => private.id
      LegalForm.create :name => "Association", :third_type_id => private.id
      LegalForm.create :name => "Etat", :third_type_id => public.id
      LegalForm.create :name => "Collectivité territoriale", :third_type_id => public.id

      # default payment methods
      virement = PaymentMethod.create :name => "Virement"
      PaymentMethod.create :name => "Chèque"
      PaymentMethod.create :name => "Espèce"
      PaymentMethod.create :name => "Lettre de change"
      PaymentMethod.create :name => "Billet à ordre"

      # default payment time limits
      comptant = PaymentTimeLimit.create :name => "Comptant"
      PaymentTimeLimit.create :name => "30 jours nets"
      PaymentTimeLimit.create :name => "60 jours nets"

      # default measure units
      UnitMeasure.create :name => "Millimètre", :symbol => "mm"
      UnitMeasure.create :name => "Centimètre", :symbol => "cm"
      UnitMeasure.create :name => "Décimètre", :symbol => "dm"
      UnitMeasure.create :name => "Mètre", :symbol => "m"
      UnitMeasure.create :name => "Millimètre carré", :symbol => "mm²"
      UnitMeasure.create :name => "Centimètretre carré", :symbol => "cm²"
      UnitMeasure.create :name => "Décimètre carré", :symbol => "dm²"
      metre_carre = UnitMeasure.create :name => "Mètre carré", :symbol => "m²"
      UnitMeasure.create :name => "Millimètre cube", :symbol => "mm³"
      UnitMeasure.create :name => "Centimètretre cube", :symbol => "cm³"
      UnitMeasure.create :name => "Décimètre cube", :symbol => "dm³"
      UnitMeasure.create :name => "Mètre cube", :symbol => "m³"
      UnitMeasure.create :name => "Millilitre", :symbol => "ml"
      UnitMeasure.create :name => "Centilitre", :symbol => "cl"
      UnitMeasure.create :name => "Décilitre", :symbol => "dl"
      UnitMeasure.create :name => "Litre", :symbol => "l"

      # default establishment types
      magasin = EstablishmentType.create :name => "Magasin"
      station = EstablishmentType.create :name => "Station service"

      # default suppliers
      iban = Iban.create :bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12"
      supplier = Supplier.create :name => "Store Concept", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id, :activated => true
      supplier.iban = iban
      supplier.save

      ibanbis = Iban.create :bank_name => "BFC", :bank_code => "12346", :branch_code => "12346", :account_number => "12345678906", :key => "16"
      supplierbis = Supplier.create :name => "Globo", :siret_number => "12345678912348", :activity_sector_id => distribution.id, :legal_form_id => sarl.id, :activated => true
      supplierbis.iban = ibanbis
      supplierbis.save

      # default customers and establishements
      customer = Customer.new(:name => "Client par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id, 
        :payment_method_id => virement.id, :payment_time_limit_id => comptant.id, :activated => true)
      
      establishment1 = Establishment.new(:name => "Mon Etablissement", :establishment_type_id => magasin.id)
      establishment2 = Establishment.new(:name => "Mon Etablissement", :establishment_type_id => magasin.id)
      establishment3 = Establishment.new(:name => "Super Etablissement", :establishment_type_id => station.id)
      establishment1.build_address(:address1 => "1 rue des rosiers", :address2 => "", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
      establishment2.build_address(:address1 => "2 rue des rosiers", :address2 => "", :country_name => "Réunion", :city_name => "Saint-Suzanne", :zip_code => "97441")
      establishment3.build_address(:address1 => "3 rue des rosiers", :address2 => "", :country_name => "Réunion", :city_name => "Saint-Marie", :zip_code => "97438")
      
      customer.establishments << [ establishment1, establishment2, establishment3 ]
      customer.save!
      
      # default contacts
      contact1 = Contact.create :first_name => "Jean-Jacques", :last_name => "Dupont", :contact_type_id => contact_customer1.id, :email => "jean-jacques@dupont.fr", :job => "Commercial"
      contact2 = Contact.create :first_name => "Pierre-Paul", :last_name => "Dupond", :contact_type_id => contact_establishment1.id, :email => "pierre-paul@dupond.fr", :job => "Commercial"

      # assign contact to client and establishment
      customer.contacts << contact1
      establishment1.contacts << contact2

      # create numbers and assign numbers to contacts
      number00 = Number.create :number => "692246801", :indicative_id => indicative.id, :number_type_id => mobile.id
      number01 = Number.create :number => "262357913", :indicative_id => indicative.id, :number_type_id => fixe.id
      contact1.numbers << number00
      contact2.numbers << number01

      # default commodity categories
      metal = CommodityCategory.create :name => "Metal"
      toles = CommodityCategory.create :name => "Tôles", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id
      tubes = CommodityCategory.create :name => "Tubes", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id

      # default commodities and their supplier_supplies
      galva = Commodity.create :name => "Galva 1500x3000x2", :reference => "glv2", :measure => "4.50", :unit_mass => "70.65",
        :commodity_category_id => toles.id, :threshold => 5
      galvabis = Commodity.create :name => "Galva 1500x3000x3", :reference => "glv3", :measure => "4.50", :unit_mass => "105.98",
        :commodity_category_id => toles.id, :threshold => 1
      galvater = Commodity.create :name => "Galva rond Ø20x2 Lg 6m", :reference => "glv6", :measure => "6", :unit_mass => "5.32",
        :commodity_category_id => tubes.id, :threshold => 18

      SupplierSupply.create({:supply_id => galva.id,
                             :supplier_id => supplier.id,
                             :reference => "glv",
                             :name => "galva",
                             :fob_unit_price => 10,
                             :tax_coefficient => 1,
                             :lead_time => 15})

      SupplierSupply.create({:supply_id => galva.id,
                             :supplier_id => supplierbis.id,
                             :reference => "galv",
                             :name => "galva_it",
                             :fob_unit_price => 11,
                             :tax_coefficient => 2,
                             :lead_time => 18})

      SupplierSupply.create({:supply_id => galvabis.id,
                             :supplier_id => supplier.id,
                             :reference => "glv2",
                             :name => "galva2",
                             :fob_unit_price => 12,
                             :tax_coefficient => 50,
                             :lead_time => 15})

      SupplierSupply.create({:supply_id => galvabis.id,
                             :supplier_id => supplierbis.id,
                             :reference => "galv2",
                             :name => "galva_it2",
                             :fob_unit_price => 25,
                             :tax_coefficient => 3,
                             :lead_time => 18})

      SupplierSupply.create({:supply_id => galvater.id,
                             :supplier_id => supplierbis.id,
                             :reference => "glv3",
                             :name => "galva",
                             :fob_unit_price => 15,
                             :tax_coefficient => 4,
                             :lead_time => 15})

      SupplierSupply.create({:supply_id => galvater.id,
                             :supplier_id => supplier.id,
                             :reference => "galv3",
                             :name => "galva_it3",
                             :fob_unit_price => 9,
                             :tax_coefficient => 0,
                             :lead_time => 18})

      # default consumable categories
      root = ConsumableCategory.create :name => "Root"
      child_one = ConsumableCategory.create :name => "Intermédiaire", :consumable_category_id => root.id, :unit_measure_id => metre_carre.id
      child_two = ConsumableCategory.create :name => "Léger", :consumable_category_id => root.id, :unit_measure_id => metre_carre.id

      # default consumables and their supplier_supplies
      pvc = Consumable.create :name => "PVC 1500x3000x2", :reference => "pvc2", :measure => "6.50", :unit_mass => "10.65",
        :consumable_category_id => child_one.id, :threshold => 2
      pvcbis = Consumable.create :name => "PVC 1500x3000x3", :reference => "pvc3", :measure => "6.50", :unit_mass => "10.98",
        :consumable_category_id => child_one.id, :threshold => 10
      vis = Consumable.create :name => "Vis Ø20x2 Lg 6m", :reference => "vis6", :measure => "0.5", :unit_mass => "0.8",
        :consumable_category_id => child_two.id, :threshold => 40

      SupplierSupply.create({:supply_id => pvc.id,
                             :supplier_id => supplierbis.id,
                             :reference => "pvc",
                             :name => "pvc-1",
                             :fob_unit_price => 8,
                             :tax_coefficient => 5,
                             :lead_time => 20})

      SupplierSupply.create({:supply_id => pvc.id,
                             :supplier_id => supplier,
                             :reference => "pvc_it",
                             :name => "pvc-it-1",
                             :fob_unit_price => 10,
                             :tax_coefficient => 1,
                             :lead_time => 15})

      SupplierSupply.create({:supply_id => pvcbis.id,
                             :supplier_id => supplier.id,
                             :reference => "pvc2",
                             :name => "pvc-12",
                             :fob_unit_price => 13,
                             :tax_coefficient => 8,
                             :lead_time => 13})

      SupplierSupply.create({:supply_id => pvcbis.id,
                             :supplier_id => supplierbis.id,
                             :reference => "pvc_it",
                             :name => "pvc-it-12",
                             :fob_unit_price => 12,
                             :tax_coefficient => 1,
                             :lead_time => 12})

      SupplierSupply.create({:supply_id => vis.id,
                             :supplier_id => supplier.id,
                             :reference => "vis2",
                             :name => "vis-12",
                             :fob_unit_price => 7,
                             :tax_coefficient => 0,
                             :lead_time => 15})

      SupplierSupply.create({:supply_id => vis.id,
                             :supplier_id => supplierbis.id,
                             :reference => "vis_it",
                             :name => "vis-it-12",
                             :fob_unit_price => 14,
                             :tax_coefficient => 0,
                             :lead_time => 11})
                             
      # default stock_flows
      StockInput.create({:supply_id => galva.id,
                         :supplier_id => supplier.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})
                         
      StockInput.create({:supply_id => galva.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => galvabis.id,
                         :supplier_id => supplier.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => galvabis.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => galvater.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => galvater.id,
                         :supplier_id => supplier.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})
      
      StockInput.create({:supply_id => pvc.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => pvc.id,
                         :supplier_id => supplier,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => pvcbis.id,
                         :supplier_id => supplier.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => pvcbis.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => vis.id,
                         :supplier_id => supplier.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      StockInput.create({:supply_id => vis.id,
                         :supplier_id => supplierbis.id,
                         :adjustment => true,
                         :fob_unit_price => 10,
                         :tax_coefficient => 0,
                         :quantity => 15,
                         :created_at => Date.yesterday.to_datetime})

      # default product reference categories
      famille1 = ProductReferenceCategory.create :name => "Famille 1"
      famille2 = ProductReferenceCategory.create :name => "Famille 2"
      famille3 = ProductReferenceCategory.create :name => "Famille 3"
      sous_famille11 = ProductReferenceCategory.create :name => "Sous famille 1.1", :product_reference_category_id => famille1.id
      sous_famille12 = ProductReferenceCategory.create :name => "Sous famille 1.2", :product_reference_category_id => famille1.id
      sous_famille13 = ProductReferenceCategory.create :name => "Sous famille 1.3", :product_reference_category_id => famille1.id
      ProductReferenceCategory.create :name => "Sous famille 2.4", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 2.1", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 2.2", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 2.3", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 3.1", :product_reference_category_id => famille3.id
      ProductReferenceCategory.create :name => "Sous famille 3.2", :product_reference_category_id => famille3.id
      ProductReferenceCategory.create :name => "Sous famille 3.3", :product_reference_category_id => famille3.id

      # default product references
      reference111 = ProductReference.create :name => "Reference 1.1.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 12233, :production_time => 2222, :delivery_cost_manpower => 1234, :delivery_time => 928, :information => 'Reference information', :reference => "XKTO89"
      reference112 = ProductReference.create :name => "Reference 1.1.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 5424, :production_time => 524245, :delivery_cost_manpower => 2542, :delivery_time => 12452543, :information => 'Reference information', :reference => "XKTO90"
      reference113 = ProductReference.create :name => "Reference 1.1.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille11.id, :production_cost_manpower => 66, :production_time => 51, :delivery_cost_manpower => 879, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO91"
      ProductReference.create :name => "Reference 1.2.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 17517, :production_time => 45245, :delivery_cost_manpower => 252544, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO92"
      ProductReference.create :name => "Reference 1.2.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 7157, :production_time => 524525, :delivery_cost_manpower => 12524524534, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO93"
      ProductReference.create :name => "Reference 1.2.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille12.id, :production_cost_manpower => 7151715, :production_time => 245245, :delivery_cost_manpower => 4524, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO94"
      ProductReference.create :name => "Reference 1.3.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 1751751, :production_time => 2225425252, :delivery_cost_manpower => 45245, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO95"
      ProductReference.create :name => "Reference 1.3.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 255425, :production_time => 2452452222, :delivery_cost_manpower => 4524524, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO96"
      ProductReference.create :name => "Reference 1.3.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille13.id, :production_cost_manpower => 122828233, :production_time => 28282248, :delivery_cost_manpower => 452542, :delivery_time => 0, :information => 'Reference information', :reference => "XKTO97"

      # default products
      Product.create :name => "Produit 1.1.1.1", :description => "Description du produit 1.1.1.1", :product_reference_id => reference111.id
      Product.create :name => "Produit 1.1.2.1", :description => "Description du produit 1.1.2.1", :product_reference_id => reference112.id
      Product.create :name => "Produit 1.1.2.2", :description => "Description du produit 1.1.2.2", :product_reference_id => reference112.id
      Product.create :name => "Produit 1.1.3.1", :description => "Description du produit 1.1.3.1", :product_reference_id => reference113.id
      Product.create :name => "Produit 1.1.3.2", :description => "Description du produit 1.1.3.2", :product_reference_id => reference113.id
      Product.create :name => "Produit 1.1.3.3", :description => "Description du produit 1.1.3.3", :product_reference_id => reference113.id

      # default society activity sectors
      SocietyActivitySector.create :name => "Enseigne"
      SocietyActivitySector.create :name => "Signalétique"
      SocietyActivitySector.create :name => "Routes"
      SocietyActivitySector.create :name => "Usinage"

      ## default_mime_type
      jpg = MimeType.create(:name => "image/jpeg")
      jpg.mime_type_extensions << MimeTypeExtension.create(:name => "jpeg")
      jpg.mime_type_extensions << MimeTypeExtension.create(:name => "jpe")
      jpg.mime_type_extensions << MimeTypeExtension.create(:name => "jpg")
      gzip = MimeType.create(:name => "application/x-gzip")
      gzip.mime_type_extensions << MimeTypeExtension.create(:name => "gz")
      pdf = MimeType.create(:name => "application/pdf")
      pdf.mime_type_extensions << MimeTypeExtension.create(:name => "pdf")
      png = MimeType.create(:name => "image/png")
      png.mime_type_extensions << MimeTypeExtension.create(:name => "png")

      ## default document types (document types are created automatically when the class of the owner is parsed)
      # for customers
      d = DocumentType.find_or_create_by_name("graphic_charter")
      d.update_attribute(:title, "Charte graphique")
      d.mime_types << [ pdf, jpg, png ]
      d = DocumentType.find_or_create_by_name("logo")
      d.update_attribute(:title, "Logo")
      d.mime_types << [ pdf, jpg, png ]
      
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
      
      ## default file types
      # for feature
#      f = FileType.create :name => "Archive de feature", :model_owner => "Feature"
#      f.mime_types << MimeType.find_by_name("application/x-gzip")
      # for employees
#      f = FileType.create :name => "CV", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f = FileType.create :name => "Lettre de motivation", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f = FileType.create :name => "Contrat de travail", :model_owner => "Employee"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
      # for step survey
#      f = FileType.create :name => "Photo Survey", :model_owner => "StepSurvey"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("image/png")
      # for step graphic conception
#      f = FileType.create :name => "Maquette", :model_owner => "StepGraphicConception"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create :name => "Plan de conception", :model_owner => "StepGraphicConception"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
      # for press proof
#      f = FileType.create :name => "PressProof", :model_owner => "PressProof"
#      f.mime_types << MimeType.find_by_name("image/png")
#      FileType.create :name => "Devis", :model_owner => "Dossier"
#      FileType.create :name => "Facture", :model_owner => "Dossier"
      # for customers
#      f = FileType.create :name => "Charte graphique", :model_owner => "Customer"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create :name => "Plan de fabrication", :model_owner => "Customer"
#      f.mime_types << MimeType.find_by_name("application/pdf")
      # for job_contracts
#      f = FileType.create :name => "Contrat de travail", :model_owner => "JobContract"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")
#      f = FileType.create :name => "Avenant au contrat", :model_owner => "JobContract"
#      f.mime_types << MimeType.find_by_name("image/jpeg")
#      f.mime_types << MimeType.find_by_name("application/pdf")
#      f.mime_types << MimeType.find_by_name("image/png")

      # default calendars and events
      calendar1 = Calendar.create :user_id => user_admin.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
      Event.create :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
      Event.create :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.days, :end_at => DateTime.now + 1.days + 2.hours
      calendar2 = Calendar.create :user_id => user_guest.id, :name => "Calendrier par défaut de Guest", :color => "blue", :title => "Titre du calendrier"
      Event.create :calendar_id => calendar2.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours

      # default employees
      john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => dg.id, :civility_id => mr.id, :family_situation_id => celib.id, :qualification => "Inconnu"
      john.numbers.build(:number => "692123456", :indicative_id => indicative.id, :number_type_id => mobile.id)
      john.numbers.build(:number => "262987654", :indicative_id => indicative.id, :number_type_id => fixe.id)
      john.build_address(:address1 => "1 rue des rosiers", :address2 => "", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
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
        employee.build_address(:address1 => "#{numbers.rand} rue des #{addresses.rand}", :address2 => "", :country_name => "#{countries.rand}", :city_name => "#{cities.rand}", :zip_code => rand(99999).to_s)
        employee.build_iban(:bank_name => banks.rand, :account_name => employee.fullname , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
        employee.service = Service.all.rand
        employee.save!
        [1,1,1,1,1,1,1,2,2,3].rand.times do |j|
          job = Job.all.rand
          ( employee.jobs << job ) unless employee.jobs.include?(job)
        end
      end

      # default calendar
      calendar_john_doe = Calendar.create :user_id => john.user.id, :name => "Calendrier de John doe", :color => "blue", :title => "Calendrier de John Doe"
      Event.create :calendar_id => calendar_john_doe.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours

      # defauts memorandums
      m1 = Memorandum.create :title => 'Note de service 1', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.months
      m2 = Memorandum.create :title => 'Note de service 2', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.months
      m3 = Memorandum.create :title => 'Note de service 3', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.months
      m4 = Memorandum.create :title => 'Note de service 4', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.weeks
      m5 = Memorandum.create :title => 'Note de service 5', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.weeks
      m6 = Memorandum.create :title => 'Note de service 6', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.weeks
      m7 = Memorandum.create :title => 'Note de service 7', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.days
      m8 = Memorandum.create :title => 'Note de service 8', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.days
      m9 = Memorandum.create :title => 'Note de service 9', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 1.days
      m10 = Memorandum.create :title => 'Note de service 10', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 3.hours
      m11 = Memorandum.create :title => 'Note de service 11', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now - 2.hours
      m12 = Memorandum.create :title => 'Note de service 12', :subject => 'Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs, Courage les mecs', :text => 'Ici il y a du texte', :signature => 'EMR Developper', :user_id => 3, :published_at => Time.now

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
      OrderType.create :title => "Normal"
      OrderType.first.society_activity_sectors = SocietyActivitySector.find(:all)
      OrderType.create :title => "SAV"
      OrderType.last.society_activity_sectors << SocietyActivitySector.first

      # default checklist
      Checklist.create :name => "Livraison sur site", :step_id => Step.find_by_name("step_survey").id
      Checklist.create :name => "Accès voiture", :step_id => Step.find_by_name("step_survey").id
      c = Checklist.create :name => "Localisation", :step_id => Step.find_by_name("step_survey").id
      c.checklist_options << ChecklistOption.create(:name => "Region NORD")
      c.checklist_options << ChecklistOption.create(:name => "Region EST")
      c.checklist_options << ChecklistOption.create(:name => "Region SUD")
      c.checklist_options << ChecklistOption.create(:name => "Region OUEST")
      c = Checklist.create :name => "Distance depuis l'entreprise", :step_id => Step.find_by_name("step_survey").id
      c.checklist_options << ChecklistOption.create(:name => "< 10 km")
      c.checklist_options << ChecklistOption.create(:name => "< 50 km")
      c.checklist_options << ChecklistOption.create(:name => "< 80 km")

      # default orders
      Order.create :title => "VISUEL NUMERIQUE GRAND FORMAT", :description => "1 visuel 10000 x 4000", :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :activity_sector_id => ActivitySector.first.id, :order_type_id => OrderType.first.id, :previsional_start => DateTime.now + 1.day, :previsional_delivery => DateTime.now + 2.days
      Order.create :title => "DRAPEAUX", :description => "4 drapeaux 400 x 700", :commercial_id => Employee.first.id, :user_id => User.first.id, :customer_id => Customer.first.id, :establishment_id => Establishment.first.id, :activity_sector_id => ActivitySector.first.id, :order_type_id => OrderType.first.id, :previsional_start => DateTime.now + 1.day, :previsional_delivery => DateTime.now + 2.days

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

    desc "Reset the database"
    task :reset => [:depopulate, :populate]

    desc "Destroy all rows for all tables of the database"
    task :destroy_all => :environment do
      puts "This task was not made yet"
    end
  end
end

