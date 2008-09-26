module ContentsHelper
  
  # This method permit to show reloaded button  
  def display_reload_button
    link_to("Actualiser la page", :action =>:edit) if @affiche == true
  end
  
  # This method permit to test permission for view_button
  def show_view_button(content)
    if controller.can_view?(current_user) and Content.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), content_path(content))
    end
  end
  
  # This method permit to test permission for add_button
  def show_add_button
    if controller.can_add?(current_user) and Content.can_add?(current_user)
      add_button = []
      add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1><ul><li>"
      add_button << link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un contenu", new_content_path)
      return add_button << "</li></ul>"
    end
  end
  
  # This method permit to test permission for edit_button
  def show_edit_button(content, value = 0)
    if value == 0
      if controller.can_edit?(current_user) and Content.can_edit?(current_user)
        link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_content_path(content))
      end
    else
      if controller.can_edit?(current_user) and Content.can_edit?(current_user)
        link_to("<img alt='Modifier' src='/images/edit_16x16.png' title='Modifier' /> Modifier le contenu", edit_content_path(content))
      end
    end
  end
  
  # This method permit to test permission for delete_button
  def show_delete_button(content)
    if controller.can_delete?(current_user) and Content.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt =>"Supprimer", :title =>"Supprimer"), content, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
  # This method permit to show contents
  def show_contents(contents)
    contents_list = []
    contents.each do |content|
      menu = Menu.find_by_id(content.menu_id)
      
      view_button = show_view_button(content)
      edit_button = show_edit_button(content)
      delete_button = show_delete_button(content)
      
      contents_list << "<tr title='#{menu.description}'>"
      contents_list << "<td>#{menu.title}</td>"
      contents_list << "<td>#{content.title}</td>"
      contents_list << "<td>#{content.description}</td>" 
      contents_list << "<td>#{view_button}  #{edit_button}  #{delete_button}</td>"
      contents_list << "</tr>"
    end
    contents_list
  end
  
  # This method permit to show content versions
  def show_contents_versions(content_versions)
    if controller.can_view?(current_user) and Content.can_view?(current_user)
      contents_versions_list = []
        contents_versions_list << "<p><ul>"
        content_versions.each_with_index do |content_version, index|
          contents_versions_list << "<li>"
          contents_versions_list << link_to(content_version.versioned_at.strftime('0%w/%m/%Y %H:%M:%S'),:controller => :content_versions, :action => :show, :content_id => content_version.content.id, :version => index+1 )
          contents_versions_list << "</li>"             
          end
          contents_versions_list << will_paginate(content_versions)
          contents_versions_list << "</ul></p>"
    end
  end
  
end