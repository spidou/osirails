module Osirails
  class Page < ActiveRecord::Base
    include Permissible
    
    include ActiveRecord::Acts::List
    include ActiveRecord::Acts::Tree
    
    acts_as_tree :order =>:position
    acts_as_list :scope => :parent_id
    
    def add_list_item(page = {})
      
    end

    def move(items = [])
      # Ne pas oublier de changer également les enfant de l'objet que l'on veut dépalcer
      
    end  
    
    def rename(page = {})
      
    end
    
    def delete_item(pages_id = [])
      
    end
    
    
  end
end