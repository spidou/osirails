class Country < ActiveRecord::Base
  # Relationships
  has_many :cities
  has_one :indicative

  # Validations
  validates_presence_of :name, :code
  validates_uniqueness_of :name
  
  has_search_index  :only_attributes => ["name", "code"],
                    :main_model => false;
end
