module PagesHelper
  
#  def show_move_buttons(page)
#    buttons = []
#    if page.move_up?
#      buttons << link_to(image_tag("up", :alt =>"up"), { :action => "move_up", :id => page.id })      
#    end
#    if page.move_down?
#      buttons << link_to(image_tag("down", :alt => "down"), { :action => "move_down", :id => page.id })
#    end
#    buttons
#  end
  
  # This method permit to show or not show a button for delete a page
  def show_actions_buttons(page)
    buttons = ""
    buttons << link_to(image_tag("edit.png", :alt => "edit"), { :action => "edit", :id => page.id })
    buttons << link_to(image_tag("delete.png", :alt => "delete"), { :action => "delete", :id => page.id })
    end
    
#  end
  
  
#  # This method insert in the $parent_array the page   
#      def return_page(pages)
#        pages.each do |page|
#          page.title_link = indent * page.ancestors.size + page.title_link if page.title_link != nil
#          parent_array << page
#          
#          #If the page has children, the insert_page method is call.
#          if page.children.size > 0
#            insert_page(page.children,parent_array,indent)
#          end
#        end
#        parent_array
#      end
      
      # tab[0] contient le text html avec les ul etc... et tab[1] contient le nombre de liste (<ul></ul>)
      def return_list(pages,tab)
        pages.each do |page|
          tab[0] += "<li id='item_"+ page.id.to_s+"'>"+page.title_link+"  "+show_actions_buttons(page)
          if page.children.size > 0
            tab[1] +=1
            tab[0]  +="<ul id=list"+tab[1].to_s+">"
            tab = return_list(page.children,tab)
            tab[0]  += "</ul>"
          end
          tab[0]  += "</li>"
        end
        tab
      end
end
