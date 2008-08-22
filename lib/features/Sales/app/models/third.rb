class Third < ActiveRecord::Base
  has_one :address, :as => :has_address
  has_one :legal_form
  has_one :payment_time_limit
  has_one :iban, :as => :has_iban
  belongs_to :activity_sector
  belongs_to :third_type
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact, :class_name => "ContactsOwners"
  has_many :contacts, :source => :contact, :foreign_key => "contact_id", :through => :contacts_owners, :class_name => "Contact"
  
  validates_presence_of :name
  validates_presence_of :activity_sector
  validates_numericality_of :siret_number, :only_integer => true
  validates_numericality_of :banking_informations, :only_integer => true
  
end