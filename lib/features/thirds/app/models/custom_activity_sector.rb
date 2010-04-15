class CustomActivitySector < ActivitySector
  has_search_index :only_attributes => [:name]
end
