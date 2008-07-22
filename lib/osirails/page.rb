module Osirails
  class Page < ActiveRecord::Base
    include Permissible
    
    acts_as_tree :order =>:position
    acts_as_list :scope => :parent_id
    
    belongs_to :parent_page, :class_name =>"Page", :foreign_key => "parent_id"
    
    # This method add a new page
    # parent : represent the future parent_page
    # new_page : is a hash that content the new page properties
    def Page.add_list_item(parent = nil, new_page = {})
      child = Page.new(:title_link => new_page[:title_link], :description_link => new_page[:description_link], :name => new_page[:name])
      unless parent.nil?
        parent.children << child
      end
      child.save
    end

    # This method permit to change the parent of a item
    # new_parent : represent the new parent            
    def move(new_parent)
       return false if new_parent.id == self.id
       return false if new_parent.parent_id == self.id
       return false if new_parent.ancestors.include?(self)
       
       self.parent_id = new_parent.id
       self.position = new_parent.children.size + 1
       self.save         
     end       
    
    def delete_item
      if base_item?(self)
        puts "This Page is a Basic page"
        return false
      end
      if has_children?(self)
        puts "This page have children. Please move them in a different page or remove them before delete the page "
        return false
      end
      self.destroy
      return true
    end
    
    # This method test if the page is a Basic item
    def base_item?(page)
      return false if page.base
    end
    
    # This method test if the page has got children
    def has_children?(page)
      page.children.empty? ? true : false
    end
    
  end
end
# Rajouter le champ type