class SocietyActivitySector < ActiveRecord::Base  
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
end
