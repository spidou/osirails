class Content < ActiveRecord::Base
  serialize :contributors
  
  belongs_to :menu
  has_many :versions, :class_name => "ContentVersion"
  validates_presence_of :title

  # This method permit to change position for a static_page
  def change_position(position)
    self.remove_from_list
    position.nil? ? self.insert_at : self.insert_at(position_in_bounds(position.to_i))
    self.move_to_bottom if position.nil?
  end
  
  def before_update
    
  end
  
end