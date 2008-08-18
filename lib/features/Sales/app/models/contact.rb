class Contact < ActiveRecord::Base
  
  has_many :contact_numbers
  validates_presence_of :first_name
  validates_presence_of :last_name
  
  # Declaration for has_many_polymorph association
  has_many :contacts_owners, :dependent => :destroy, :foreign_key => "contact_id", :class_name => "ContactsOwners"
  has_many :thirds, :source => :has_contact, :through => :contacts_owners, :source_type => "Third", :class_name => "Third"
  
end