module Osirails
  class Page < ActiveRecord::Base
    include Permissible
    
    include ActiveRecord::Acts::List
    include ActiveRecord::Acts::Tree
    
    acts_as_tree :order =>:position, :counter_cache => :pages_count
    acts_as_list :scope => :parent_id
    
    belongs_to :parent_page, :class_name =>"Page", :foreign_key => "parent_id"
    
    def add_list_item()
      
    end

    # This methods permit to change the parent of a item group 
    # new_parent : represent the new parent
    # pages : represent the pages collection for the parent changing    
    
    def Page.move(new_parent, pages = [])
      Page.transaction do
        pages.each do |page|
          p = Page.new(:title_link => page.title_link, :description_link => page.description_link, :url => page.url , :name => page.name)
          p.parent_id = new_parent.id
          p.save
          page.destroy
        end
      end
    end  
      
    def rename(page = {})
      
    end
    
    def delete_item(pages_id = [])
      
    end
  end
end
