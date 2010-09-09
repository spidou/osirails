class EstablishmentType < ActiveRecord::Base
  has_many :establishments
  validates_presence_of :name
  
  has_search_index :only_attributes => [:name]
end
