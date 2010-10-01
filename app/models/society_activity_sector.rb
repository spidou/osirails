class SocietyActivitySector < ActiveRecord::Base  
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
  
  has_search_index :only_attributes => [:name]
  
  # for pagination : number of instances by index page
  SOCIETY_ACTIVITY_SECTORS_PER_PAGE = 15
end
