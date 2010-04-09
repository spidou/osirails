class CustomActivitySector < ActiveRecord::Base
  has_search_index :only_attributes => [:name]
end
