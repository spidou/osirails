class Civility < ActiveRecord::Base
  # Relationships
  has_many :employees

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
end
