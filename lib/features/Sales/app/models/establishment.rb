class Establishment  < ActiveRecord::Base
  has_one :address, :as => :has_address
  has_many  :contacts, :as => :has_contacts
  belongs_to :customer
  belongs_to :establishment_type
  validates_presence_of :name
  validates_presence_of :address
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact, :class_name => "ContactsOwners"
  has_many :contacts, :source => :contact, :foreign_key => "contact_id", :through => :contacts_owners, :class_name => "Contact"
end