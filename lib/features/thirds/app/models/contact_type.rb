class ContactType < ActiveRecord::Base
  # Relationships
  has_many :contacts

  # Validations
  validates_presence_of :name, :owner
end