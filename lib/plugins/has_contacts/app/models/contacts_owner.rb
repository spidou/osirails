class ContactsOwner < ActiveRecord::Base
  belongs_to :contact
  belongs_to :has_contact, :polymorphic => true
  
  validates_presence_of :contact_id, :has_contact_type
end
