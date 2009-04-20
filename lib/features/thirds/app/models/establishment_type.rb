class EstablishmentType < ActiveRecord::Base
  # Relationships
  has_many :establishments

  # Validations
  validates_presence_of :name
end