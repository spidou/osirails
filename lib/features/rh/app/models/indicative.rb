class Indicative < ActiveRecord::Base
  # Relationships
  has_many :numbers
  belongs_to :country

  # Validations
  validates_presence_of :country_id, :indicative
  
  has_search_index :only_attributes => [:indicative]
end
 
