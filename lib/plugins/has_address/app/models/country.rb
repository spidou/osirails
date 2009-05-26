class Country < ActiveRecord::Base
  # Relationships
  has_many :cities
  has_one :indicative

  # Validations
  validates_presence_of :name, :code
  validates_uniqueness_of :name
end
