class Establishment  < ActiveRecord::Base
  has_permissions :as_business_object
  has_address :address, :one_or_many => :many
  
  has_many  :contacts, :as => :has_contacts
  belongs_to :customer
  belongs_to :establishment_type
  validates_presence_of :name
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact
  has_many :contacts, :source => :contact, :through => :contacts_owners
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom de l'enseigne :"
  @@form_labels[:establishment_type] = "Type d'établissement :"
  
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
