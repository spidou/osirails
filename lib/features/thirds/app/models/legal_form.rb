class LegalForm < ActiveRecord::Base
  # Relationships
  belongs_to :third_type
  belongs_to :third

  # Validations
  validates_presence_of :name
  
  has_search_index :only_attributes => [:name]
end
