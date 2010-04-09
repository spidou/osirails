namespace :osirails do
  namespace :db do
    desc "Populate the database with simple entries in simple tables"
    task :load_default_data => :environment do
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
      
      role_admin = Role.create! :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
      
      user_admin.roles << role_admin

      # default activity sectors
      ActivitySectorReference.create! :code => "10.11Z",
        :activity_sector        => ActivitySector.create!(:name => "Industries Alimentaires"),
        :custom_activity_sector => CustomActivitySector.create!(:name => "Alimentation")
        
      ActivitySectorReference.create! :code => "13.10Z",
        :activity_sector        => ActivitySector.create!(:name => "Fabrication de textiles"),
        :custom_activity_sector => CustomActivitySector.create!(:name => "Textile/Habillement")
        
      ActivitySectorReference.create! :code => "42.11Z",
        :activity_sector        => ActivitySector.create!(:name => "Génie civil"),
        :custom_activity_sector => CustomActivitySector.create!(:name => "Construction")
        
      ActivitySectorReference.create! :code => "27.40Z",
        :activity_sector        => ActivitySector.create!(:name => "Fabrication d'équipements électriques"),
        :custom_activity_sector => nil
      
      
      # default third types
      private_third_type  = ThirdType.create! :name => "Privé"
      public_third_type   = ThirdType.create! :name => "Public"
      
      # default legal forms
      LegalForm.create! :name => "Association",                   :third_type_id => private_third_type.id
      LegalForm.create! :name => "Entreprise individuelle",       :third_type_id => private_third_type.id
      LegalForm.create! :name => "Établissement scolaire privé",  :third_type_id => private_third_type.id
      LegalForm.create! :name => "EURL",                          :third_type_id => private_third_type.id
      LegalForm.create! :name => "Particulier",                   :third_type_id => private_third_type.id
      LegalForm.create! :name => "SA",                            :third_type_id => private_third_type.id
      LegalForm.create! :name => "SARL",                          :third_type_id => private_third_type.id
      LegalForm.create! :name => "SAS",                           :third_type_id => private_third_type.id
      LegalForm.create! :name => "SASU",                          :third_type_id => private_third_type.id
      LegalForm.create! :name => "SNC",                           :third_type_id => private_third_type.id
      LegalForm.create! :name => "Société mutuelle",              :third_type_id => private_third_type.id
      LegalForm.create! :name => "Agence publique",               :third_type_id => public_third_type.id
      LegalForm.create! :name => "Entreprise publique",           :third_type_id => public_third_type.id
      LegalForm.create! :name => "Établissement scolaire public", :third_type_id => public_third_type.id
      LegalForm.create! :name => "Etat",                          :third_type_id => public_third_type.id
      LegalForm.create! :name => "Collectivité territoriale",     :third_type_id => public_third_type.id
      
      # default payment method
      
      five = PaymentTimeLimit.create! :name => "60 jours après réception des travaux + facilité de paiement éventuelle"
      four = PaymentTimeLimit.create! :name => "30 jours après réception des travaux + facilité de paiement éventuelle"
      tree = PaymentTimeLimit.create! :name => "30 jours + sans facilité de paiement éventuelle"
      two = PaymentTimeLimit.create! :name => "0 jours + facilité de paiement éventuelle"
      one = PaymentTimeLimit.create! :name => "0 jours + sans facilité de paiement"
      zero = PaymentTimeLimit.create! :name => "Refus Client"
      
      # default payment time limit
      
      a_method = PaymentMethod.create! :name => "Tout moyen de paiement accordé"
      b_method = PaymentMethod.create! :name => "CB/Espèces/Chèque/Virement/Prélèvement"
      c_method = PaymentMethod.create! :name => "CB/Espèces/Chèque/Virement"
      d_method = PaymentMethod.create! :name => "CB/Espèces/Chèque"
      e_method = PaymentMethod.create! :name => "Espèces/Chèque"
      f_method = PaymentMethod.create! :name => "Refus du Client"
      
      # default customer grades
      
      CustomerGrade.create! :name => "5/5", :payment_time_limit => five
      CustomerGrade.create! :name => "4/5", :payment_time_limit => four
      CustomerGrade.create! :name => "3/5", :payment_time_limit => tree
      CustomerGrade.create! :name => "2/5", :payment_time_limit => two
      CustomerGrade.create! :name => "1/5", :payment_time_limit => one
      CustomerGrade.create! :name => "0/5", :payment_time_limit => zero
      
      # default customer solvencies
      
      CustomerSolvency.create! :name => "100%", :payment_method => a_method
      CustomerSolvency.create! :name => "80%", :payment_method => b_method
      CustomerSolvency.create! :name => "60%", :payment_method => c_method
      CustomerSolvency.create! :name => "40%", :payment_method => d_method
      CustomerSolvency.create! :name => "20%", :payment_method => e_method
      CustomerSolvency.create! :name => "0%", :payment_method => f_method
      
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
      EstablishmentType.create! :name => "Siège administratif"
      EstablishmentType.create! :name => "Entrepôt"
      EstablishmentType.create! :name => "Magasin/Boutique"
      EstablishmentType.create! :name => "Station service"
      EstablishmentType.create! :name => "Concession"
      EstablishmentType.create! :name => "Grande surface"
      EstablishmentType.create! :name => "Agence"
      EstablishmentType.create! :name => "Organisme public"
      EstablishmentType.create! :name => "Atelier"
      EstablishmentType.create! :name => "Usine"
      EstablishmentType.create! :name => "Autre"
        
      # default VAT rates
      Vat.create! :name => "19.6",  :rate => "19.6"
      Vat.create! :name => "8.5",   :rate => "8.5"
      Vat.create! :name => "5.5",   :rate => "5.5"
      Vat.create! :name => "2.1",   :rate => "2.1"
      Vat.create! :name => "Exo.",  :rate => "0"
          
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
      
      #default delivery_note_types
      DeliveryNoteType.create! :title => "Livraison + Installation", :delivery => true,   :installation => true
      DeliveryNoteType.create! :title => "Livraison",                :delivery => true,   :installation => false
      DeliveryNoteType.create! :title => "Enlèvement Client",        :delivery => false,  :installation => false
      
      # default invoice_types
      InvoiceType.create! :name => Invoice::DEPOSITE_INVOICE, :title => "Acompte",    :factorisable => false
      InvoiceType.create! :name => Invoice::STATUS_INVOICE,   :title => "Situation",  :factorisable => true
      InvoiceType.create! :name => Invoice::BALANCE_INVOICE,  :title => "Solde",      :factorisable => true
      InvoiceType.create! :name => Invoice::ASSET_INVOICE,    :title => "Avoir",      :factorisable => false
      
      %W{ BusinessObject Menu DocumentType Calendar }.each do |klass|
        klass.constantize.all.each do |object|
          object.permissions.each do |permission|
            permission.permissions_permission_methods.each do |object_permission|
              object_permission.update_attribute(:active, true)
            end
          end
        end
      end
    end
  end
end
