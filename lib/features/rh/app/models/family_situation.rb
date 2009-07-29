class FamilySituation < ActiveRecord::Base
  # Relationships
  has_many :employees

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_search_index
end
