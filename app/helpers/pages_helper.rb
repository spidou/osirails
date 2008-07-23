module PagesHelper
  
  #This method return an array with all pages
  def get_pages_array
    pages = Osirails::Page.find_all_by_parent_id(nil)
    parent_array = []
    
    # This method insert in the $parent_array the page
    def insert_page(pages,parent_array)
      pages.each do |page|
      parent_array << page
          
          #If the page has children, the insert_page method is call.
          if page.children.size > 0
            insert_page(page.children,parent_array)
          end
        end
    end
    insert_page(pages,parent_array)
    parent_array
  end
end
