namespace :osirails do
  namespace :db do
    desc "Populate the database"
    task :populate => :environment do
      # default civilities
      Civility.create :name => "Mr"
      Civility.create :name => "Mme"
      Civility.create :name => "Mademoiselle"
      
      # default family situations
      FamilySituation.create :name => "Célibataire"
      FamilySituation.create :name => "Marié(e)"
      FamilySituation.create :name => "Veuf/Veuve"
      FamilySituation.create :name => "Divorcé(e)" 
      
      # default number types
      NumberType.create :name => "Mobile"
      NumberType.create :name => "Fixe"
      NumberType.create :name => "Fax"
      NumberType.create :name => "Mobile Professionnel"
      NumberType.create :name => "Fixe Professionnel"
      NumberType.create :name => "Fax Professionnel"
      
      # default employee states
      EmployeeState.create :name => "Titulaire"
      EmployeeState.create :name => "Stagiaire"
      EmployeeState.create :name => "Licencié(e)"
      EmployeeState.create :name => "Démissionnaire"
      
      # default job contract types
      JobContractType.create :name => "CDI"
      JobContractType.create :name => "CDD"
      
      # default countries
      france = Country.create :name => "France"
      reunion = Country.create :name => "Réunion"
      spain = Country.create :name => "Espagne"
      united_kingdom = Country.create :name => "Angleterre"
      germany = Country.create :name => "Allemagne"
      japan = Country.create :name => "Japon"
      china = Country.create :name => "Chine"
      
      # default indicatives
      Indicative.create :indicative => "+262", :country_id => reunion.id
      Indicative.create :indicative => "+33",:country_id=> france.id 
      Indicative.create :indicative => "+34", :country_id => spain.id
      Indicative.create :indicative => "+44", :country_id => united_kingdom.id
      Indicative.create :indicative => "+49", :country_id => germany.id
      Indicative.create :indicative => "+81", :country_id => japan.id
      Indicative.create :indicative => "+86", :country_id => china.id
      
      # default services
      dg = Service.create :name => "Direction Générale"
      Service.create :name => "Service Administratif", :service_parent_id => dg.id
      Service.create :name => "Service Commercial", :service_parent_id => dg.id
      prod = Service.create :name => "Production", :service_parent_id => dg.id
      Service.create :name => "Atelier Décor", :service_parent_id => prod.id
      Service.create :name => "Atelier Découpe", :service_parent_id => prod.id
      Service.create :name => "Atelier Fraisage", :service_parent_id => prod.id 
      
      # default roles
      role_admin = Role.create  :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
      role_guest = Role.create  :name => "guest" ,:description => "Ce rôle permet un accés à toutes les ressources publiques en lecture seule" 
      
      # default contact types
      ContactType.create :name => "Normal", :owner => "Customer"
      ContactType.create :name => "Contact de facturation", :owner => "Customer"
      ContactType.create :name => "Contact de livraison", :owner => "Customer"
      ContactType.create :name => "Normal", :owner => "Establishment"
      ContactType.create :name => "Contact de livraison", :owner => "Establishment"    
      ContactType.create :name => "Acceuill", :owner => "Establishment"
      ContactType.create :name => "Normal", :owner => "Supplier"
      
      # default users and roles
      user_admin = User.create :username => "admin" ,:password => "admin", :enabled => 1
      user_guest = User.create :username => "guest",:password => "guest", :enabled => 1
      user_admin.roles << role_admin
      user_guest.roles << role_guest
      
      # default menu permissions for default roles
      Menu.find(:all).each do |m|
        MenuPermission.create :list => 1, :view => 1, :add => 1,:edit => 1, :delete => 1, :role_id => role_admin.id, :menu_id => m.id # admin
        MenuPermission.create :list => 1, :view => 1, :add => 0,:edit => 0, :delete => 0, :role_id => role_guest.id, :menu_id => m.id # guest
      end
      
      # default business object permissions for default roles
      bo = []                               # put all business objects into the array 'bo'
      Feature.find(:all).each do |f|        #
        unless f.business_objects.nil?      #
          f.business_objects.each do |g|    #
            bo << g unless bo.include?(g)   #
          end                               #
        end                                 #
      end                                   #
      bo.each do |m|
        BusinessObjectPermission.create :list => 1, :view => 1, :add => 1,:edit => 1, :delete => 1, :role_id => role_admin.id, :has_permission_type => m[0] # admin
        BusinessObjectPermission.create :list => 1, :view => 1, :add => 0,:edit => 0, :delete => 0, :role_id => role_guest.id, :has_permission_type => m[0] # aall
      end
      
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
      EstablishmentType.create :name => "Magasin"
      EstablishmentType.create :name => "Station service"
      
      # default suppliers
      iban = Iban.create :bank_name => "Bred", :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12"
      supplier = Supplier.create :name => "Fournisseur par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id
      supplier.iban = iban
      
      # default customers
      Customer.create :name => "Client par défaut", :siret_number => "12345678912345", :activity_sector_id => distribution.id, :legal_form_id => sarl.id, 
        :payment_method_id => virement.id, :payment_time_limit_id => comptant.id
      
      # default commodity categories
      metal = CommodityCategory.create :name => "Metal"
      toles = CommodityCategory.create :name => "Tôles", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id
      tubes = CommodityCategory.create :name => "Tubes", :commodity_category_id => metal.id, :unit_measure_id => metre_carre.id
      
      # default commodities
      Commodity.create :name => "Galva 1500x3000x2", :fob_unit_price => "26.88", :taxe_coefficient => "0", :measure => "4.50", :unit_mass => "70.65",
        :commodity_category_id => toles.id, :supplier_id => supplier.id
      Commodity.create :name => "Galva 1500x3000x3", :fob_unit_price => "45.12", :taxe_coefficient => "0", :measure => "4.50", :unit_mass => "105.98",
        :commodity_category_id => toles.id, :supplier_id => supplier.id
      Commodity.create :name => "Galva rond Ø20x2 Lg 6m", :fob_unit_price => "1.63", :taxe_coefficient => "0", :measure => "6", :unit_mass => "5.32",
        :commodity_category_id => tubes.id, :supplier_id => supplier.id
      
      # default product reference categories
      famille1 = ProductReferenceCategory.create :name => "Famille 1"
      famille2 = ProductReferenceCategory.create :name => "Famille 2"
      famille3 = ProductReferenceCategory.create :name => "Famille 3"
      sous_famille11 = ProductReferenceCategory.create :name => "Sous famille 1.1", :product_reference_category_id => famille1.id
      sous_famille12 = ProductReferenceCategory.create :name => "Sous famille 1.2", :product_reference_category_id => famille1.id
      sous_famille13 = ProductReferenceCategory.create :name => "Sous famille 1.3", :product_reference_category_id => famille1.id
      ProductReferenceCategory.create :name => "Sous famille 2.1", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 2.2", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 2.3", :product_reference_category_id => famille2.id
      ProductReferenceCategory.create :name => "Sous famille 3.1", :product_reference_category_id => famille3.id
      ProductReferenceCategory.create :name => "Sous famille 3.2", :product_reference_category_id => famille3.id
      ProductReferenceCategory.create :name => "Sous famille 3.3", :product_reference_category_id => famille3.id
      
      # default product references
      reference111 = ProductReference.create :name => "Reference 1.1.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille11.id
      reference112 = ProductReference.create :name => "Reference 1.1.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille11.id
      reference113 = ProductReference.create :name => "Reference 1.1.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille11.id
      ProductReference.create :name => "Reference 1.2.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille12.id
      ProductReference.create :name => "Reference 1.2.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille12.id
      ProductReference.create :name => "Reference 1.2.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille12.id
      ProductReference.create :name => "Reference 1.3.1", :description => "Description de la référence 1.1.1", :product_reference_category_id => sous_famille13.id
      ProductReference.create :name => "Reference 1.3.2", :description => "Description de la référence 1.1.2", :product_reference_category_id => sous_famille13.id
      ProductReference.create :name => "Reference 1.3.3", :description => "Description de la référence 1.1.3", :product_reference_category_id => sous_famille13.id
      
      # default products
      Product.create :name => "Produit 1.1.1.1", :description => "Description du produit 1.1.1.1", :product_reference_id => reference111.id
      Product.create :name => "Produit 1.1.1.2", :description => "Description du produit 1.1.1.2", :product_reference_id => reference111.id
      Product.create :name => "Produit 1.1.1.3", :description => "Description du produit 1.1.1.3", :product_reference_id => reference111.id
      Product.create :name => "Produit 1.1.2.1", :description => "Description du produit 1.1.2.1", :product_reference_id => reference112.id
      Product.create :name => "Produit 1.1.2.2", :description => "Description du produit 1.1.2.2", :product_reference_id => reference112.id
      Product.create :name => "Produit 1.1.2.3", :description => "Description du produit 1.1.2.3", :product_reference_id => reference112.id
      Product.create :name => "Produit 1.1.3.1", :description => "Description du produit 1.1.3.1", :product_reference_id => reference113.id
      Product.create :name => "Produit 1.1.3.2", :description => "Description du produit 1.1.3.2", :product_reference_id => reference113.id
      Product.create :name => "Produit 1.1.3.3", :description => "Description du produit 1.1.3.3", :product_reference_id => reference113.id
      
      # default society activity sectors
      SocietyActivitySector.create :name => "Enseigne"
      SocietyActivitySector.create :name => "Signalétique"
      SocietyActivitySector.create :name => "Routes"
      SocietyActivitySector.create :name => "Usinage"
      
      # default file types
      f = FileType.create :name => "CV", :model_owner => "Employee"
      f.file_type_extensions << FileTypeExtension.create(:name =>"doc")
      f.file_type_extensions << FileTypeExtension.create(:name =>"docx")
      f.file_type_extensions << FileTypeExtension.create(:name =>"odt")
      f.file_type_extensions << FileTypeExtension.create(:name =>"pdf")
      
      f = FileType.create :name => "Lettre de motivation", :model_owner => "Employee"
      f.file_type_extensions << FileTypeExtension.find_by_name("doc")
      f.file_type_extensions << FileTypeExtension.find_by_name("docx")
      f.file_type_extensions << FileTypeExtension.find_by_name("odt")
      
      f = FileType.create :name => "Contrat de travail", :model_owner => "Employee"
      f.file_type_extensions << FileTypeExtension.find_by_name("doc")
      f.file_type_extensions << FileTypeExtension.find_by_name("docx")
      f.file_type_extensions << FileTypeExtension.find_by_name("odt")
      
      FileType.create :name => "Photo Survey", :model_owner => "Dossier"
      FileType.create :name => "Plan conception", :model_owner => "Dossier"
      FileType.create :name => "Maquette", :model_owner => "Dossier"
      FileType.create :name => "Devis", :model_owner => "Dossier"
      FileType.create :name => "Facture", :model_owner => "Dossier"

      # default calendars and events
      calendar1 = Calendar.create :user_id => user_admin.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
      Event.create :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
      Event.create :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.days, :end_at => DateTime.now + 1.days + 2.hours
      calendar2 = Calendar.create :user_id => user_guest.id, :name => "Calendrier par défaut de Guest", :color => "blue", :title => "Titre du calendrier"
      Event.create :calendar_id => calendar2.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
    end
    

    desc "Depopulate the database"
    task :depopulate => :environment do
      [Role,User,Civility,FamilySituation,BusinessObjectPermission,MenuPermission,NumberType,Indicative,Job,JobContractType,
        JobContract,Service,EmployeeState,ThirdType,Employee,ContactType,Salary,Premium,Country,LegalForm,PaymentMethod,PaymentTimeLimit,
        UnitMeasure,EstablishmentType,Supplier,Iban,Customer,Commodity,CommodityCategory,Product,ProductReference,ProductReferenceCategory,
        SocietyActivitySector,ActivitySector,FileType,FileTypeExtension].each do |model|
        
        puts "destroying all rows for model '#{model.name}'"
        model.destroy_all
      end
    end

    desc "Reset the database"
    task :reset => [:depopulate, :populate]
    
    desc "Destroy all rows for all tables of the database"
    task :destroy_all => :environment do
      puts "This task was not made yet"
    end
  end
end
