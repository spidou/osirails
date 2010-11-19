class Civility < ActiveRecord::Base
  has_many :employees
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [:name, :id],
                   :identifier      => :name
end
