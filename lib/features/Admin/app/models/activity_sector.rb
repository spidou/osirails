class ActivitySector < ActiveRecord::Base
  belongs_to :customers
  belongs_to :supplier
  
  validates_presence_of :name
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
end
