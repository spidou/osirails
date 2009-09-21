class ContactsOwner < ActiveRecord::Base
  # Relationhips
  belongs_to :contact
  belongs_to :has_contact, :polymorphic => true

  # Validations
  validates_presence_of :contact_id
end
