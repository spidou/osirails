module PagesHelper
  def get_pages_array
    
    def boucles
      pages.each do |page|
      @@parent_array << page
          if page.children.size > 0
            Page.get_structure(page.children)
          end
        end
    end
            
          
  end
end
