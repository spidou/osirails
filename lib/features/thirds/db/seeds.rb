require 'lib/seed_helper'

# default third types
private_third_type  = ThirdType.create! :name => "Privé"
public_third_type   = ThirdType.create! :name => "Public"

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

# default legal forms
LegalForm.create! :name => "Agent Commercial",                                                    :third_type_id => private_third_type.id
LegalForm.create! :name => "Artisan",                                                             :third_type_id => private_third_type.id
LegalForm.create! :name => "Association loi 1901 ou assimilé",                                    :third_type_id => private_third_type.id
LegalForm.create! :name => "Autre groupement de droit privé non doté de la personnalité morale",  :third_type_id => private_third_type.id
LegalForm.create! :name => "Autre personne physique",                                             :third_type_id => private_third_type.id
LegalForm.create! :name => "Caisse d'épargne et de prévoyance",                                   :third_type_id => private_third_type.id
LegalForm.create! :name => "CE",                                                                  :third_type_id => private_third_type.id
LegalForm.create! :name => "Commerçant",                                                          :third_type_id => private_third_type.id
LegalForm.create! :name => "Entreprise individuelle",                                             :third_type_id => private_third_type.id
LegalForm.create! :name => "Établissement scolaire privé",                                        :third_type_id => private_third_type.id
LegalForm.create! :name => "EURL",                                                                :third_type_id => private_third_type.id
LegalForm.create! :name => "GIE",                                                                 :third_type_id => private_third_type.id
LegalForm.create! :name => "Organisme mutualiste",                                                :third_type_id => private_third_type.id
LegalForm.create! :name => "Particulier",                                                         :third_type_id => private_third_type.id
LegalForm.create! :name => "Profession libérale",                                                 :third_type_id => private_third_type.id
LegalForm.create! :name => "Personne morale de droit étranger,  immatriculée au RCS",             :third_type_id => private_third_type.id
LegalForm.create! :name => "Société en commandite",                                               :third_type_id => private_third_type.id
LegalForm.create! :name => "SA",                                                                  :third_type_id => private_third_type.id
LegalForm.create! :name => "SARL",                                                                :third_type_id => private_third_type.id
LegalForm.create! :name => "SAS",                                                                 :third_type_id => private_third_type.id
LegalForm.create! :name => "SASU",                                                                :third_type_id => private_third_type.id
LegalForm.create! :name => "SNC",                                                                 :third_type_id => private_third_type.id
LegalForm.create! :name => "Société civile",                                                      :third_type_id => private_third_type.id
LegalForm.create! :name => "Société mutuelle",                                                    :third_type_id => private_third_type.id

LegalForm.create! :name => "Administration de l'État",                                                :third_type_id => public_third_type.id
LegalForm.create! :name => "Agence publique",                                                         :third_type_id => public_third_type.id
LegalForm.create! :name => "Entreprise publique",                                                     :third_type_id => public_third_type.id
LegalForm.create! :name => "Établissement public administratif",                                      :third_type_id => public_third_type.id
LegalForm.create! :name => "Établissement public ou régie à caractère industriel ou commercial",      :third_type_id => public_third_type.id
LegalForm.create! :name => "Établissement scolaire public",                                           :third_type_id => public_third_type.id
LegalForm.create! :name => "Collectivité territoriale",                                               :third_type_id => public_third_type.id
LegalForm.create! :name => "Organisme gérant un régime de protection sociale à adhésion obligatoire", :third_type_id => public_third_type.id
LegalForm.create! :name => "Organisme professionnel",                                                 :third_type_id => public_third_type.id

# default granted payment times
gpt1 = GrantedPaymentTime.create! :name => "Solde à la livraison"
gpt2 = GrantedPaymentTime.create! :name => "Solde à 30 jours"
gpt3 = GrantedPaymentTime.create! :name => "Solde à 60 jours"

# default granted payment methods
gpm1 = GrantedPaymentMethod.create! :name => "Tout moyen de paiement accordé"
gpm2 = GrantedPaymentMethod.create! :name => "Paiement par chèque"
gpm3 = GrantedPaymentMethod.create! :name => "Paiement par virement"

# default customer grades
CustomerGrade.create! :name => "5/5", :granted_payment_method => gpm1
CustomerGrade.create! :name => "4/5", :granted_payment_method => gpm1
CustomerGrade.create! :name => "3/5", :granted_payment_method => gpm2
CustomerGrade.create! :name => "2/5", :granted_payment_method => gpm2
CustomerGrade.create! :name => "1/5", :granted_payment_method => gpm2
CustomerGrade.create! :name => "0/5", :granted_payment_method => gpm2

# default customer solvencies
CustomerSolvency.create! :name => "100%", :granted_payment_time => gpt2
CustomerSolvency.create! :name => "80%",  :granted_payment_time => gpt2
CustomerSolvency.create! :name => "60%",  :granted_payment_time => gpt2
CustomerSolvency.create! :name => "40%",  :granted_payment_time => gpt1
CustomerSolvency.create! :name => "20%",  :granted_payment_time => gpt1
CustomerSolvency.create! :name => "0%",   :granted_payment_time => gpt1

## default document types for customers (document types are created automatically when the class of the owner is parsed)
#### get mime types
pdf = MimeType.find_by_name("application/pdf")
jpg = MimeType.find_by_name("image/jpeg")
png = MimeType.find_by_name("image/png")
####
dt = DocumentType.find_or_create_by_name("graphic_charter")
dt.update_attribute(:title, "Charte graphique")
dt.mime_types << [ pdf, jpg, png ]
dt = DocumentType.find_or_create_by_name("logo")
dt.update_attribute(:title, "Logo")
dt.mime_types << [ pdf, jpg, png ]
dt = DocumentType.find_or_create_by_name("photo")
dt.update_attribute(:title, "Photo")
dt.mime_types << [ jpg, png ]

set_default_permissions
