class Menu < ActiveRecord::Base
  has_permissions :as_instance, :instance_methods => [ :access ]
  has_permissions :as_business_object
  setup_has_permissions_model
  
  # Relationship
  belongs_to :parent_menu, :class_name => "Menu", :foreign_key => "parent_id"
  belongs_to :feature

  # Plugin
  acts_as_tree :order => :position
  acts_as_list :scope => :parent_id

  # Accessor
  attr_accessor :parent_array
  
  # Store the ancient parent_id before update parent
  attr_accessor :old_parent_id, :update_parent
  
  # Named scopes
  named_scope :mains, :order => "position" ,:conditions => {:parent_id => nil}
  named_scope :activated, :order => "position", :include => [:feature], :conditions => ['(features.activated = true or menus.name IS NULL) and menus.hidden IS NULL']
 
  # Validation Macros
  validates_presence_of :title, :message => "ne peut être vide"
  
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
  
  def last_ancestor(menu = self)
    menu.ancestors.size > 0 ? ( menu.ancestors.size == 1 ? menu.parent_menu : last_ancestor(menu.parent_menu) ) : menu
  end
  
  def insert_at(position = 0)
    super(position_in_bounds(position))
  end
  
  # This method permit to change the parent of a item
  # new_parent : represent the new parent            
  def change_parent(new_parent_id,position = nil)
    if self.can_has_this_parent?(new_parent_id) and new_parent_id.to_s != self.parent_id.to_s
      self.remove_from_list
      self.parent_id = new_parent_id
      position.nil? ? self.insert_at : self.insert_at(position)
      self.move_to_bottom if position.nil?
      self.save
    end
  end
  
  # This method permit to view if a child can have a new_parent
  def can_has_this_parent?(new_parent_id)
    return true if new_parent_id.blank?
    new_parent = Menu.find(new_parent_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self)
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
    
#  # Permits to get how many siblings are not actived, so to move properly all menus
#  def how_many_brother_activated(sign)
#    menus = Menu.mains.activated
#    menu_position = self.position
#    number = 0
#    brothers = []
#    
#    if sign == 'lower'
#      self.siblings.sort_by(&:position).each do |brother|
#        brothers << brother if menu_position < brother.position
#      end
#      brothers.each do |brother|
#        if menus.include?(brother)
#          return number += 1
#        else
#          number += 1
#        end
#      end
#    elsif sign == 'higher'
#      self.siblings.sort_by(&:position).each do |brother|
#        brothers << brother if menu_position > brother.position
#      end
#      brothers.reverse.each do |brother|
#        if menus.include?(brother)
#          return number += 1
#        else
#          number += 1
#        end
#      end
#    end    
#    number += 1
#  end  
    
  # This method test if it possible to move up the menu
  def can_move_up?
    self.self_and_siblings.first.position != self.position
  end
    
  # This method test if it possible to move down  the menu
  def can_move_down?
    self.self_and_siblings.size > self.position
  end
  
  def move_up
    return false unless can_move_up?
    self.move_higher
  end
  
  def move_down
    return false unless can_move_down?
    self.move_lower
  end
  
  # This method return an array with all menus
  # Current_menu_id permit to hide menu in select menu parent
  def self.get_structured_menus(current_menu_id = nil)
    menus = Menu.mains.activated
    parents = []
    root = Menu.new
    root.title = "  "
    root.id = nil
    parents = get_children(menus, current_menu_id, parents)
    parents
  end
  
  private
    # This method insert in the parents the menus   
    def self.get_children(menus, current_menu_id, parents)
      menus.each do |menu|
        unless menu.id == current_menu_id
          parents << menu
          # If the menu has children, the get_children method is call.
          if menu.children.size > 0
            get_children(menu.children, current_menu_id, parents)
          end
        end
      end
      parents
    end
      
  protected
    # This method permit to return a valide position for a menu.
    def position_in_bounds(position)
      if position < 1 
        1
      elsif position > self.self_and_siblings.size
        self.self_and_siblings.size
      else
        position
      end
    end
end
