class MockupType < ActiveRecord::Base
  # Relationships
  has_many :mockups

  # Validations
  validates_uniqueness_of :name
  validates_presence_of :name
end
