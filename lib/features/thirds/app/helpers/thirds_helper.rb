module ThirdsHelper
  
  # display edit button in the secondary menu
  def display_edit_button_in_second_menu(third)
    raise "TypeError. third must be either Customer or Supplier instance. third = #{third.class.name}" unless third.kind_of?(Third)
    third_name = third.kind_of?(Supplier) ? "fournisseur" : "client"
    
    if can_edit?(third)
      html = "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1>"
      html << "<ul>"
      html << "<li>" + link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier") + " Modifier le #{third_name}", send("edit_#{third.class.name.downcase}_path",third)) + "</li>"
      html << "</ul>"
    end
  end
  
end