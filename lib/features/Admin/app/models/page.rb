class Page < ActiveRecord::Base
  include Permissible
  
  # Plugin
  acts_as_tree :order =>:position
  acts_as_list :scope => :parent_id
  
  # Relationship
  belongs_to :parent_page, :class_name =>"Page", :foreign_key => "parent_id"
  
  # Accessor
  attr_accessor :parent_array
 
  # Validation Macros
  validates_presence_of :title_link, :message => "ne peut être vide"

  # This method permit to change the parent of a item
  # new_parent : represent the new parent            
  def change_parent(new_parent_id,position = nil)
    if self.can_has_this_parent?(new_parent_id) and new_parent_id != self.parent_id.to_s
      self.remove_from_list
      self.parent_id = new_parent_id
      position.nil? ? self.insert_at : self.insert_at(position_in_bounds(position))
      self.move_to_bottom if position.nil?
      self.save
    end
  end       
  
  # This method permit to view if a child can have a new_parent
  def can_has_this_parent?(new_parent_id)
    return true if new_parent_id == ""
    new_parent = Page.find(new_parent_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self)
    true
  end
  
  # This method permit to verify if a page can be delete or not
  def can_delete?
    !base_item? and !has_children?
  end
    
  # This method test if the page is a Basic item
  def base_item?
    self.name != nil ? true : false
  end
    
  # This method test if the page has got children
  def has_children?
    self.children.size > 0 ? true : false
  end
    
  # This method test if it possible to move up the page
  def can_move_up?
    return false if self.position == 1
    return true
  end
    
  # This method test if it possible to move down  the page
  def can_move_down?
    first_parent = Page.find_all_by_parent_id(nil)
    parent = Page.find_by_id(self.parent_id)
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
    
  #This method return an array with all pages
  def Page.get_structured_pages(indent)
    pages = Page.nav_item.find_all_by_parent_id(nil, :order => :position)
    parents = []
    root = Page.new
    root.title_link = "  "
    root.id =nil
    parents = get_children(pages,parents,indent)
    parents
  end
    
  private
  # This method insert in the parents the page   
  def Page.get_children(pages,parents,indent)
    pages.each do |page|
      page.title_link = indent * page.ancestors.size + page.title_link if page.title_link != nil
      parents << page
          
      # If the page has children, the get_children method is call.
      if page.children.size > 0
        get_children(page.children,parents,indent)
      end
    end
    parents
  end


  # This position permit to return a valide position for a page.
  def position_in_bounds(position)
    if position < 1 
      1
    elsif position > self.self_and_siblings.size
      self.parent.children.size
    else
      position
    end
  end
    
end
