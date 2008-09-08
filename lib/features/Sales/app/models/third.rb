class Third < ActiveRecord::Base
  # To get Document
  acts_as_file

  has_one :address, :as => :has_address
  
  belongs_to :activity_sector
  belongs_to :third_type
  belongs_to :legal_form
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact, :class_name => "ContactsOwners"
  has_many :contacts, :source => :contact, :foreign_key => "contact_id", :through => :contacts_owners, :class_name => "Contact"
  
  validates_presence_of :name
  validates_presence_of :legal_form_id
  validates_presence_of :activity_sector
  validates_format_of :siret_number, :with => /^[0-9]{14}/
  
end