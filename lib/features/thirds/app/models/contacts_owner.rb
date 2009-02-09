class ContactsOwner < ActiveRecord::Base
  belongs_to :contact
  belongs_to :has_contact, :polymorphic => true
end
