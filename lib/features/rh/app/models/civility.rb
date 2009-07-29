class Civility < ActiveRecord::Base
  # Relationships
  has_many :employees

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # Search Plugin 
  has_search_index :only_attributes => ["name"]
end
