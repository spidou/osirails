class Approaching < ActiveRecord::Base
  validates_presence_of :name
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [:name, :id],
                   :identifier      => :name
end
