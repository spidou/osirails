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

# default payment time limit
ptl1 = PaymentTimeLimit.create! :name => "60 jours après réception des travaux + facilité de paiement éventuelle"
ptl2 = PaymentTimeLimit.create! :name => "30 jours après réception des travaux + facilité de paiement éventuelle"
ptl3 = PaymentTimeLimit.create! :name => "30 jours + sans facilité de paiement éventuelle"
ptl4 = PaymentTimeLimit.create! :name => "0 jours + facilité de paiement éventuelle"
ptl5 = PaymentTimeLimit.create! :name => "0 jours + sans facilité de paiement"
ptl6 = PaymentTimeLimit.create! :name => "Refus Client"

# default payment method
pm1 = PaymentMethod.create! :name => "Tout moyen de paiement accordé"
pm2 = PaymentMethod.create! :name => "CB/Espèces/Chèque/Virement/Prélèvement"
pm3 = PaymentMethod.create! :name => "CB/Espèces/Chèque/Virement"
pm4 = PaymentMethod.create! :name => "CB/Espèces/Chèque"
pm5 = PaymentMethod.create! :name => "Espèces/Chèque"
pm6 = PaymentMethod.create! :name => "Refus du Client"

# default customer grades
CustomerGrade.create! :name => "5/5", :payment_time_limit => ptl1
CustomerGrade.create! :name => "4/5", :payment_time_limit => ptl2
CustomerGrade.create! :name => "3/5", :payment_time_limit => ptl3
CustomerGrade.create! :name => "2/5", :payment_time_limit => ptl4
CustomerGrade.create! :name => "1/5", :payment_time_limit => ptl5
CustomerGrade.create! :name => "0/5", :payment_time_limit => ptl6

# default customer solvencies
CustomerSolvency.create! :name => "100%", :payment_method => pm1
CustomerSolvency.create! :name => "80%",  :payment_method => pm2
CustomerSolvency.create! :name => "60%",  :payment_method => pm3
CustomerSolvency.create! :name => "40%",  :payment_method => pm4
CustomerSolvency.create! :name => "20%",  :payment_method => pm5
CustomerSolvency.create! :name => "0%",   :payment_method => pm6

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
