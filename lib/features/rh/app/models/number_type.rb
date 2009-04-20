class NumberType < ActiveRecord::Base
  # Relationships
  has_many :numbers

  # Validations
  validates_presence_of :name
end
