class CustomActivitySector < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  has_search_index :only_attributes => [:name]
end
