class Establishment  < ActiveRecord::Base
  has_permissions :as_business_object
  has_address :address, :one_or_many => :many
  has_contacts
  
  has_documents :photos

  belongs_to :customer
  belongs_to :establishment_type
  belongs_to :activity_sector_reference
  
  has_number :phone
  has_number :fax
  
  validates_presence_of   :name, :address, :establishment_type, :siret_number
  validates_format_of     :siret_number, :with => /^[0-9]{14}$/, :message => "Le numéro SIRET doit comporter 14 chiffres"
  validates_uniqueness_of :siret_number
  validates_associated    :address
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  # Search Plugin
  has_search_index :only_attributes    => [ :name, :activated ],
                   :only_relationships => [ :contacts, :address ]
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]                = "Nom de l'enseigne :"
  @@form_labels[:establishment_type]  = "Type d'établissement :"
  @@form_labels[:siret_number]        = "N° Siret :"
  @@form_labels[:activity_sector_reference] = "Code NAF :"
  @@form_labels[:phone]               =  "Téléphone fixe :"
  @@form_labels[:fax]                 =  "Fax :"
  
  
  def name_and_full_address
    "#{self.name} (#{self.full_address})"
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
end
