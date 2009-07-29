class ActivitySector < ActiveRecord::Base
  validates_presence_of :name
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
  
  has_search_index :only_attributes => ["name"]
end
