module PagesHelper
  
  #This method return an array with all pages
  def get_pages_array
    pages = Osirails::Page.find_all_by_parent_id(nil, :order => :position)
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
  puts "nim"
  
  def show_move_buttons(page)
    buttons = []
    if page.move_up?
      buttons << link_to("up", { :action => "move_up", :id => page.id })      
    end
    if page.move_down?
      buttons << link_to("down", { :action => "move_down", :id => page.id })
    end
    buttons
  end
  
  def show_actions_buttons(page)
    buttons = []
    buttons << link_to("Delete", { :action => "delete", :id => page.id })
  end
end
