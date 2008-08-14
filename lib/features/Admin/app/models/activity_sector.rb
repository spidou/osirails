class ActivitySector < ActiveRecord::Base
  belongs_to :customers
  belongs_to :supplier
  
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
end
