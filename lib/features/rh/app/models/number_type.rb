class NumberType < ActiveRecord::Base
  has_many :numbers
  
  validates_presence_of :name
  
  has_search_index :only_attributes => [:name]
end
