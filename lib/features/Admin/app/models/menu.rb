class Menu < ActiveRecord::Base
  # Relationship
  belongs_to :parent_menu, :class_name =>"Menu", :foreign_key => "parent_id"
  has_many :menu_permissions
  has_one :content

  # Plugin
  acts_as_tree :order =>:position
  acts_as_list :scope => :parent_id

  # Accessor
  attr_accessor :parent_array
  
  # Store the ancient parent_id before update parent
  attr_accessor :old_parent_id, :update_parent
 
  # Validation Macros
  validates_presence_of :title, :message => "ne peut être vide"
  
  # Includes
  include Permissible::InstanceMethods
  
  def before_update
    if self.update_parent
      @new_parent_id, self.parent_id = self.parent_id, self.old_parent_id
      self.can_has_this_parent?(@new_parent_id)
    end
  end

 
  def after_update
    if self.update_parent
      self.update_parent = false
      self.change_parent(@new_parent_id)
    end
  end
  
  # This method permit to change the parent of a item
  # new_parent : represent the new parent            
  def change_parent(new_parent_id,position = nil)
    if self.can_has_this_parent?(new_parent_id) and new_parent_id.to_s != self.parent_id.to_s
      self.remove_from_list
      self.parent_id = new_parent_id
      position.nil? ? self.insert_at : self.insert_at(position_in_bounds(position))
      self.move_to_bottom if position.nil?
      self.save
    end
  end       
  
  # This method permit to view if a child can have a new_parent
  def can_has_this_parent?(new_parent_id)
    return true if new_parent_id == "" or new_parent_id.nil?
    new_parent = Menu.find(new_parent_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self) or !new_parent.content.nil?
    true
  end
 
  # This method permit to verify if a menu can be delete or not
  def can_delete_menu?
    !base_item? and !has_children?
  end
    
  # This method test if the menu is a Basic item
  def base_item?
    self.name != nil ? true : false
  end
    
  # This method test if the menu has got children
  def has_children?
    self.children.size > 0 ? true : false
  end
    
  # This method test if it possible to move up the menu
  def can_move_up?
    return false if self.position == 1
    return true
  end
    
  # This method test if it possible to move down  the menu
  def can_move_down?
    first_parent = Menu.find_all_by_parent_id(nil)
    parent = Menu.find_by_id(self.parent_id)
    if self.ancestors.size > 0
      return false if parent.children.size == self.position
      return true
    end
    if self.ancestors.size <= 0
      return false if first_parent.size == self.position
      return true
    end
    return false
  end
    
  #This method return an array with all menus
  def Menu.get_structured_menus(indent)
    menus = Menu.find_all_by_parent_id(nil, :order => :position)
    parents = []
    root = Menu.new
    root.title = "  "
    root.id =nil
    parents = get_children(menus,parents,indent)
    parents
  end
    
  private
  # This method insert in the parents the menus   
  def Menu.get_children(menus,parents,indent)
    menus.each do |menu|
      menu.title = indent * menu.ancestors.size + menu.title if menu.title != nil
      parents << menu
          
      # If the menu has children, the get_children method is call.
      if menu.children.size > 0
        get_children(menu.children,parents,indent)
      end
    end
    parents
  end
  
  protected
  # This position permit to return a valide position for a menu.
  def position_in_bounds(position)
    if position < 1 
      1
    elsif position > self.self_and_siblings.size
      puts self.self_and_siblings.size
      self.self_and_siblings.size
    else
      position
    end
  end
  
end
