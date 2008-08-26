# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def file_upload
    file_field 'upload', 'datafile'
  end
  
  def display_flash
    html = ""
    flash.each_pair do |key, value|
      html << '<br/>' unless html == ""
      html << "<span class=\"flash_#{key}\"><span>#{value}</span></span>"
    end
    html == "" ? "" : "<div class=\"flash_container\">" << html << "</div>"
  end
  
  def current_user
    session[:user]
  end
  
  def current_menu
    Menu.find_by_name(controller.controller_name) or raise "The controller '#{controller.controller_name}' should have a menu with the same name"
  end
  
  def link_to_menu(menu, content = nil)
    # OPTIMIZE optimize this IF block code
    if menu.name
      path = menu.name + "_path"
      if self.respond_to?(path)
        link_to(content || menu.title, self.send(path))
      else
        link_to(content || menu.title, :controller => menu.name)
      end
    else
      link_to(content || menu.title)
    end
  end
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.each do |m|
      selected = (menu == m or menu.ancestors.include?(m) ? "class=\"selected\"" : "")
      html << "<li #{selected} title=\"#{m.description}\">" + link_to_menu(m) + "</li>\n"
    end
    html
  end
  
  def display_second_menu
    html = []
    menu = current_menu
    main_menu = menu.last_ancestor
    #return if main_menu.nil?
    main_menu.children.each do |m|
      first = main_menu.children.first == m ? "id=\"menu_horizontal_first\"": "" #detect if is the first element
      selected = ( ( menu == m or menu.ancestors.include?(m) ) ? "class=\"selected\"" : "") #detect if the element is selected
      html << link_to_menu(m, "<span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span></a>")
    end
    html.reverse.to_s
  end
  
  def display_welcome_message
    "Bienvenue, " + ( current_user ? ( current_user.employee ? "#{current_user.employee.fullname}" : "\"#{current_user.username}\"" ) : "" )
  end
  
  def display_date_time
    Date::today.strftime("Nous sommes le %A %d %B et il est %C:%M")
  end
  
  def my_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    if(tag_options[:index])
      tag_name = "new_#{object}#{tag_options[:index]}_#{method}"
    else
      tag_name = "new_#{object}#{method}"
    end
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
      
#        text_field(object, method, tag_options) +
        content_tag("input", "", :id => "new_#{object}#{tag_options[:index]}_#{method}", :type => "text", :size => 30, 
        :name => "new_#{object}#{tag_options[:index]}[#{method}]", :autocomplete => "off") +
        content_tag("div", "", :id => tag_name + "_auto_complete", :class => "auto_complete") +
        auto_complete_field(tag_name, { :url => {:controller => "#{tag_options[:url][:controller]}", :action => "auto_complete_for_#{object}_#{method}", :country_id => tag_options[:country_id]} }.update(completion_options))
                                                                
  end
end
