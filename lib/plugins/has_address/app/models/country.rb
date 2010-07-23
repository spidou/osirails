class Country < ActiveRecord::Base
  has_many :cities
  
  validates_presence_of :name, :code
  validates_uniqueness_of :name
  
  has_search_index  :only_attributes => [:name, :code]
end
