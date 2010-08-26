require 'lib/seed_helper'

# default users and roles
user_admin = User.create! :username => "admin", :password => "admin", :enabled => 1
role_admin = Role.create! :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
user_admin.roles << role_admin

# default number types
NumberType.create! :name => "Mobile"
NumberType.create! :name => "Fixe"
NumberType.create! :name => "Fax"
NumberType.create! :name => "Mobile Professionnel"
NumberType.create! :name => "Fixe Professionnel"
NumberType.create! :name => "Fax Professionnel"

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
dirg = Service.create! :name => "Direction Générale"
Service.create! :name => "Administratif et Financier", :service_parent_id => dirg.id
Service.create! :name => "Commercial",                 :service_parent_id => dirg.id
Service.create! :name => "Achats/Ventes",              :service_parent_id => dirg.id
Service.create! :name => "Informatique",               :service_parent_id => dirg.id

prod = Service.create! :name => "Production",          :service_parent_id => dirg.id
Service.create! :name => "Électricité",                :service_parent_id => prod.id
Service.create! :name => "Métallerie",                 :service_parent_id => prod.id
Service.create! :name => "Peinture",                   :service_parent_id => prod.id
Service.create! :name => "Plasturgie",                 :service_parent_id => prod.id
Service.create! :name => "Décor",                      :service_parent_id => prod.id
Service.create! :name => "Pose",                       :service_parent_id => prod.id

# default society activity sectors
SocietyActivitySector.create! :name => "Enseigne"
SocietyActivitySector.create! :name => "Signalétique"
SocietyActivitySector.create! :name => "Routes"
SocietyActivitySector.create! :name => "Usinage"

## default_mime types
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
    
# default checklists #TODO these default values may be in another place (in acts_as_step plugin, or sales feature)
checklist1 = Checklist.create! :name => "environment_checklist_for_end_products_in_survey_step", :title => "Checklist des contraintes de pose à la visite commerciale", :description => "Checklist à remplir pour chaque produit de la commande lors de la visite commerciale"
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

# default permissions
%W{ BusinessObject Menu DocumentType }.each do |klass|
  klass.constantize.all.each do |object|
    object.permissions.each do |permission|
      permission.permissions_permission_methods.each do |object_permission|
        object_permission.update_attribute(:active, true)
      end
    end
  end
end
