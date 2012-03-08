require 'lib/seed_helper'

# personalized_queries
Query.create! do |q| # Draft Quotes (for quote management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.draft_quotes')
  q.criteria      = { 'status' => { :action => '=', :value => '' } }
  q.page_name     = "quote_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "commercial_actor.fullname", "validity_delay", "total_with_taxes", "deposit", "order.quotation_deadline"]
  q.order         = ["created_at:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Signed Quotes (for quote management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.signed_quotes')
  q.criteria      = { 'status' => { :action => '=', :value => 'signed' } }
  q.page_name     = "quote_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "commercial_actor.fullname", "reference", "published_on", "total_with_taxes", "deposit", "signed_on"]
  q.order         = ["signed_on:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Cancelled Quotes (for quote management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.cancelled_quotes')
  q.criteria      = { 'status' => { :action => '=', :value => 'cancelled' } }
  q.page_name     = "quote_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "commercial_actor.fullname", "reference", "published_on", "sended_on", "total_with_taxes", "deposit", "cancelled_at"]
  q.order         = ["cancelled_at:desc"]
  q.public_access = true
  q.per_page      = 25
end


Query.create! do |q| # Sent Invoices (for invoice management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.sent_invoices')
  q.criteria      = { 'sended_on' => { :action => '!=', :value => '' } }
  q.page_name     = "invoice_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "global_granted_delay", "number_of_due_dates", "upcoming_due_date", "factorised?", "delivery_notes", "sended_on", "status"]
  q.order         = ["sended_on:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Draft Invoices (for invoice management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.draft_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => '' } }
  q.page_name     = "invoice_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "global_granted_delay", "number_of_due_dates", "upcoming_due_date", "factorised?"]
  q.order         = ["sended_on:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Abandoned Invoices (for invoice management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.abandoned_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => 'abandoned' } }
  q.page_name     = "invoice_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "already_paid_amount", "factorised?", "abandoned_on", "abandoned_comment"]
  q.order         = ["abandoned_on:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Cancelled Invoices (for invoice management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.cancelled_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => 'cancelled' } }
  q.page_name     = "invoice_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "factorised?", "cancelled_at", "cancelled_comment"]
  q.order         = ["cancelled_at:desc"]
  q.public_access = true
  q.per_page      = 25
end


Query.create! do |q| # Totally Paid Invoices (for payment management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.totally_paid_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => 'totally_paid,factoring_balance_paid' } }
  q.page_name     = "payment_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "factorised?"]
  q.order         = ["cancelled_at:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Abandoned Invoices (for payment management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.abandoned_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => 'abandoned' } }
  q.page_name     = "payment_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "already_paid_amount", "factorised?", "abandoned_on", "abandoned_comment"]
  q.order         = ["abandoned_on:desc"]
  q.public_access = true
  q.per_page      = 25
end

Query.create! do |q| # Cancelled Invoices (for payment management)
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.cancelled_invoices')
  q.criteria      = { 'status' => { :action => '=', :value => 'cancelled' } }
  q.page_name     = "payment_management_index"
  q.search_type   = "and"
  q.columns       = ["order.reference", "order.title", "order.customer.name", "invoice_contact.fullname", "reference", "invoice_type.title", "net_to_paid", "factorised?", "cancelled_at", "cancelled_comment"]
  q.order         = ["cancelled_at:desc"]
  q.public_access = true
  q.per_page      = 25
end

# default payment methods
PaymentMethod.create! :name => "Chèque"
PaymentMethod.create! :name => "Carte bancaire"
PaymentMethod.create! :name => "Espèce"
PaymentMethod.create! :name => "Virement"
PaymentMethod.create! :name => "Mandat"
PaymentMethod.create! :name => "Prélèvement"

# default VAT rates
Vat.create! :name => "19.6",  :rate => "19.6"
Vat.create! :name => "8.5",   :rate => "8.5"
Vat.create! :name => "5.5",   :rate => "5.5"
Vat.create! :name => "2.1",   :rate => "2.1"
Vat.create! :name => "Exo.",  :rate => "0"

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
DunningSendingMethod.create!(:name => "Courrier + Accusé de réception + lettre de mise en demeure")

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

## default document types (document types are created automatically when the class of the owner is parsed)
#### get mime types
pdf = MimeType.find_by_name("application/pdf")
jpg = MimeType.find_by_name("image/jpeg")
png = MimeType.find_by_name("image/png")
####
# for products
d = DocumentType.find_or_create_by_name("plan")
d.update_attribute(:title, "Plan")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("mockup")
d.update_attribute(:title, "Maquette")
d.mime_types << [ pdf, jpg, png ]

# for subcontractor_requests
d = DocumentType.find_or_create_by_name("quote")
d.update_attribute(:title, "Devis")
d.mime_types << [ pdf, jpg, png ]

set_default_permissions
