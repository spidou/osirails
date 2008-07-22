module Osirails
  class Page < ActiveRecord::Base
    include Permissible
    
    include ActiveRecord::Acts::List
    include ActiveRecord::Acts::Tree
    
    acts_as_tree :order =>:position, :counter_cache => true
    acts_as_list :scope => :parent_id
    
    belongs_to :parent_page, :class_name =>"Page", :foreign_key => "parent_id", :counter_cache => :pages_count
    
    def add_list_item(page = {})
      
    end

    # This methods permit to change the parent of a item group 
    # new_parent_id : represent the new parent_id
    # pages_id : represent the pages collection for the parent changing    
    def Page.move(new_parent_id, pages_id = [])
      # Ne pas oublier de changer également les enfant de l'objet que l'on veut dépalcer
      pages_id.each do |page|
        child = Page.find_by_id(page)
        parent_page = Page.find_by_id(new_parent_id)
        parent_page.children << child
        child.move_to_bottom
        parent_page.save
        child.save                
      end
    end  
    
    def rename(page = {})
      
    end
    
    def delete_item(pages_id = [])
      
    end
    
    
  end
end