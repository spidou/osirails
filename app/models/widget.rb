class Widget < ActiveRecord::Base
  belongs_to :user
  
  acts_as_list :scope => 'user_id = \'#{user_id}\' AND col = \'#{col}\''
  
  validates_presence_of :user_id
  validates_presence_of :user, :if => :user_id
  
  validates_numericality_of :col, :position, :greater_than => 0
end
