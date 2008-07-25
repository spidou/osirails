module Osirails
  class Page < ActiveRecord::Base
    include Permissible
    
    acts_as_tree :order =>:position
    acts_as_list :scope => :parent_id
    
    belongs_to :parent_page, :class_name =>"Page", :foreign_key => "parent_id"
    attr_accessor :parent_array
 
    
    # This method add a new page
    # parent : represent the future parent_page
    # new_page : is a hash that content the new page properties
    def Page.add_list_item(parent = nil, new_page = {})
      child = Page.new(:title_link => new_page[:title_link], :description_link => new_page[:description_link])
      unless parent.nil?
        parent.children << child
      end
      child.save
    end

    # This method permit to change the parent of a item
    # new_parent : represent the new parent            
    def change_parent(new_parent)
      unless new_parent.nil?
        if self.can_has_this_parent?(new_parent)
          self.parent_id = new_parent.id
          self.position = new_parent.children.size + 1
          self.save        
        end
      else
        unless self.parent_id.nil?
          first_parent = Page.find_all_by_parent_id(nil)
          self.parent_id = nil
          self.position = first_parent.size + 1
          self.save
        end
      end
    end       
     
    def can_has_this_parent?(new_parent)
      return false if new_parent.id == self.id
      return false if new_parent.id == self.parent_id
      return false if new_parent.ancestors.include?(self)
      return true
    end

    # This method permit to delete a page. She check if this page have a child or is a base_item
    def delete
      return false if base_item?
      return false if has_children?
      self.destroy
      return true
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
    def move_up?
      return false if self.position == 1
      return true
    end
    
    # This method test if it possible to move down  the page
    def move_down?
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
    
#    def display_flash_notice(method)
#      case method
#      when "delete"
#        message = self.title_link + " est supprimé."
#      when "confirm_edit"
#        message = self.title_link + " est bien modifié."
#      when "create"
#        message = self.title_link + " est bien créée."
#      end
#      return message
#    end
#    
#    def display_flash_error(method)
#      case method
#      when "delete"
#        message = "Erreur" # child
#      when "confirm_edit"
#        message = "Erreur" # Can be him self in : Child, himself
#      when "create"
#        message = "Erreur" # .....
#      end
#      return message
#    end
    
    #This method return an array with all pages
    def Page.get_pages_array(indent)
      pages = Osirails::Page.find_all_by_parent_id(nil, :order => :position)
      parent_array = []
      root = Page.new
      root.title_link = "  "
      root.id =nil
      parent_array = insert_page(pages,parent_array,indent)
      parent_array
    end
    
    private
    # This method insert in the $parent_array the page   
      def Page.insert_page(pages,parent_array,indent)
        pages.each do |page|
          page.title_link = indent * page.ancestors.size + page.title_link if page.title_link != nil
          parent_array << page
          
          #If the page has children, the insert_page method is call.
          if page.children.size > 0
            insert_page(page.children,parent_array,indent)
          end
        end
        parent_array
      end
    
  end
end