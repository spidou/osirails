class ContactsOwners < ActiveRecord::Base
  belongs_to :contact
  belongs_to :has_contact, :polymorphic => true
  
  # Validate uniqueness of an instance in the table
#   validates_uniqueness_of :contact_id, :scope => [ :has_contact_id,:has_contact_type ]

end
