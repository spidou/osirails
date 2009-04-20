class ThirdType < ActiveRecord::Base
  # Relationships
  has_many :legal_forms

  # Validations
  validates_presence_of :name
end