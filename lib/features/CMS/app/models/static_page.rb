class StaticPage < Page
  serialize :contributors
  
  belongs_to :parent_page, :class_name =>"StaticPage", :foreign_key => "parent_id"
  validates_presence_of :title

  # This method permit to change position for a static_page
  def change_position(position)
    self.remove_from_list
    position.nil? ? self.insert_at : self.insert_at(position_in_bounds(position.to_i))
    self.move_to_bottom if position.nil?
  end   
  
end