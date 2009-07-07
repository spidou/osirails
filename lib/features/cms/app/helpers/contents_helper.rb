module ContentsHelper
  
  # This method permit to show reloaded button  
  def display_reload_button
    link_to("Actualiser la page", :action =>:edit) if @affiche == true
  end
  
  
  # This method permit to show contents
  def show_contents(contents)
    contents_list = []
    contents.each do |content|
      menu = Menu.find_by_id(content.menu_id)
      
      view_button = content_link(content, :link_text => "")
      edit_button = edit_content_link(content, :link_text => "")
      delete_button = delete_content_link(content, :link_text => "")
      
      contents_list << "<tr title='#{content.menu.description}'>"
      contents_list << "<td>#{content.menu.title}</td>"
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
        contents_versions_list << link_to(content_version.versioned_at.to_datetime.humanize, :controller => :content_versions, :action => :show, :content_id => content_version.content.id, :version => index+1 )
        contents_versions_list << "</li>"             
      end
      contents_versions_list << will_paginate(content_versions)
      contents_versions_list << "</ul></p>"
    end
  end
  
  def contributors_full_names(contributors)
    full_name = []
    contributors.each do |contributor|
      full_name << (contributor.employee.nil? ? contributor.username : contributor.employee.fullname)
    end
    full_name.join(', ')
  end
end
