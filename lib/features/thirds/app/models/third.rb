class Third < ActiveRecord::Base
  has_address :address
  
  belongs_to :activity_sector
  belongs_to :third_type
  belongs_to :legal_form
  belongs_to :payment_method
  belongs_to :payment_time_limit
  
  validates_presence_of :name, :legal_form, :siret_number, :activity_sector
  validates_format_of :siret_number, :with => /^[0-9]{14}/, :allow_blank => true #even if its presence is required, to avoid double error message #, :message => "doit comporter 14 chiffres"
  
  RATINGS = { "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5 }
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:legal_form] = "Forme juridique :"
  @@form_labels[:siret_number] = "Numéro SIRET :"
  @@form_labels[:activity_sector] = "Secteur d'activit&eacute; :"
  @@form_labels[:activities] = "Activités :"
  @@form_labels[:note] = "Note :"
  @@form_labels[:payment_method] = "Moyen de paiement préféré :"
  @@form_labels[:payment_time_limit] = "Délai de paiement préféré :"
  
end
