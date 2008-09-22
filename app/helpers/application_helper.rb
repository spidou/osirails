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
    html.empty? ? "" : "<div class=\"flash_container\">" << html << "</div>"
  end
  
  def current_user
    begin
      User.find(session[:user])
    rescue
      return false
    end
  end
  
  def current_menu
    step = controller.current_order_step if controller.respond_to?("current_order_step")
    menu = step || controller.controller_name
    Menu.find_by_name(menu) or raise "The controller '#{controller.controller_name}' should have a menu with the same name"
  end
  
  def url_for_menu(menu)
    # OPTIMIZE optimize this IF block code
    if menu.name
      path = menu.name + "_path"
      if self.respond_to?(path)
        self.send(path)
      else
        url_for(:controller => menu.name)
      end
    else
      unless menu.content.nil?
        url_for(:controller => "contents", :action => "show", :id => menu.content.id)
      else
        ""
      end
    end
  end
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.activated.each do |m|
      selected = (menu == m or menu.ancestors.include?(m) ? "class=\"selected\"" : "")
      html << "<li #{selected} title=\"#{m.description}\">#{link_to(m.title, url_for_menu(m))}</li>\n"
    end
    html
  end
  
  def display_second_menu
    html = []
    menu = current_menu
    main_menu = menu.last_ancestor
    main_menu.children.activated.each do |m|
      first = main_menu.children.first == m ? "id=\"menu_horizontal_first\"": "" #detect if is the first element
      selected = ( ( menu == m or menu.ancestors.include?(m) ) ? "class=\"selected\"" : "") #detect if the element is selected
      html << link_to("<span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span>", url_for_menu(m))
    end
    html.reverse.to_s
  end
  
  def display_tabulated_menu
    html = "<div class=\"tabs\"><ul>"
    menu = current_menu
    menu.self_and_siblings.activated.each do |m|
      selected = ( m == menu ? "class=\"selected\"" : "" )
      html << "<li #{selected} title=\"#{m.description}\">" + link_to(m.title, url_for_menu(m)) + "</li>"
    end
    html << "</ul></div>"
  end
  
  def display_welcome_message
    "Bienvenue, " + ( current_user ? ( current_user.employee ? "#{current_user.employee.fullname}" : "\"#{current_user.username}\"" ) : "" )
  end
  
  def display_date_time
    day = DateTime.now.strftime("%A").downcase
    DateTime.now.strftime("Nous sommes le #{day} %d %B %Y, il est %H:%M")
  end
  
  def my_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    
    ## Hack by Ulrich
    unless tag_options[:name].nil?
      temp = tag_options[:name].split('_')
      new_name = temp.shift
      temp.each{|a| new_name += '['+a+']'}
    end
    ############
    
    if(tag_options[:index])
      tag_id = "#{tag_options[:name]}_#{object}s_#{tag_options[:index]}_#{method}"
      tag_name = "#{new_name}[#{object}s][#{tag_options[:index]}][#{method}]"
    else
      tag_id = "#{tag_options[:name]}_#{object}_#{method}"
      tag_name = "#{new_name}[#{object}][#{method}]"
    end
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
      
    content_tag("input", "", :id => tag_id, :type => "text", :size => 30, 
      :name => tag_name, :autocomplete => "off") +
      content_tag("div", "", :id => tag_id + "_auto_complete", :class => "auto_complete") +
      auto_complete_field(tag_id, { :url => {:controller => "#{tag_options[:controller]}", :action => "auto_complete_for_#{object}_#{method}"} }.update(completion_options))
                                                                
  end
  
  def display_memorandums
    under_banner = []
    under_banner << "<div id='text_under_banner'>"	#<!-- Limiter le texte à 297 caractères !! [Sous risque de bug] -->
		under_banner << "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse semper, arcu non rhoncus fermentum,
				nisl odio semper pede, a pellentesque erat dui sit amet elit. Sed pede est, tempus a, fringilla eu, suscipit eget,
				lorem. In feugiat suscipit dolor. Lorem ipsum dolor sit amet, consectetuer. AA"
		under_banner << "</div>"
		under_banner <<	"<div id='block_button_under_banner'>"
		under_banner << "<input type='button' id='previous' alt='bouton précédent' title='Information précédente'/>"
		under_banner << "<span class='number'>02</span>|<span class='number'>10</span>"
		under_banner << "<input type='button' id='next' alt='bouton suivant' title='Information suivante'/>"
		under_banner << "</div>"
  end
  
end
