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
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.activated.each do |m|
      selected = (menu == m or menu.ancestors.include?(m) ? "class=\"selected\"" : "")
      html << "<li #{selected} title=\"#{m.description}\" class=\"disabled\">#{link_to(m.title, "#")}</li>\n" if m.can_list?(current_user) and !m.can_view?(current_user)
      html << "<li #{selected} title=\"#{m.description}\">#{link_to(m.title, url_for_menu(m))}</li>\n" if m.can_list?(current_user) and m.can_view?(current_user)
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
      html << link_to("<span title=\"#{m.description}\" #{selected} #{first} class=\"disabled\">#{m.title}</span>", "#") if m.can_list?(current_user) and !m.can_view?(current_user)
      html << link_to("<span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span>", url_for_menu(m)) if m.can_list?(current_user) and m.can_view?(current_user)
    end
    html.reverse.to_s
  end
  
  def display_tabulated_menu
    html = "<div class=\"tabs\"><ul>"
    menu = current_menu
    menu.self_and_siblings.activated.each do |m|
      selected = ( m == menu ? "class=\"selected\"" : "" )
      html << "<li #{selected} title=\"#{m.description}\" class=\"disabled\">#{link_to(m.title, "#")}</li>" if m.can_list?(current_user) and !m.can_view?(current_user)
      html << "<li #{selected} title=\"#{m.description}\">#{link_to(m.title, url_for_menu(m))}</li>" if m.can_list?(current_user) and m.can_view?(current_user)
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
  
  # This method permit to make diplay memorandums under banner
  def display_memorandums
    under_banner = []
    unless current_user.employee.nil?
      size = last_memorandums.size
      memorandum_number = ( size == 0 ? "0" : "1" )
      under_banner << "<div id='text_under_banner' style='overflow: hidden;' onclick='show_memorandum(this, 0)'>"
      under_banner << last_memorandums
      under_banner << "</div>"
      under_banner <<	"<div id='block_button_under_banner'>"
      under_banner << "<input type='button' id='previous' class='previous_memorandum_#{size}' alt='bouton précédent' title='Information précédente' onclick='change_memorandum(this, #{size}, event)'  />"
      under_banner << "<span class='number'> #{memorandum_number} </span>|<span class='number'> #{size} </span>"
      under_banner << "<input type='button' id='next' class='next_memorandum_2' alt='bouton suivant' title='Information suivante' onclick='change_memorandum(this, #{size}, event)'  />"
      under_banner << "</div>"
    else
      under_banner << "<span id='not_employee_reference'>Vous ne pouvez recevoir de notes de service car vous n'&ecirc;tes pas associ&eacute; &agrave; un employ&eacute;</span>"
    end
  end
   
  # This method permit to recover last 10 memorandums
  def last_memorandums
    unless current_user.employee.nil?
      memorandums = Memorandum.find_by_services(current_user.employee.services)
      last_memorandum = []
      max_memorandums = 0
      memorandums.each do |memorandum|
        unless memorandum.published_at.nil?
          max_memorandums += 1
          last_memorandum << format_memorandum(memorandum, max_memorandums) if max_memorandums < 11
        end
      end
    
      last_memorandum.reverse
    end
  end
  
  # This method permit to format memorandum
  def format_memorandum(memorandum, max_memorandums)
      formated_memorandum = []
      memorandum_signature = "<strong>"+memorandum.signature+".</strong>"
      memorandum_date = "<span class='memorandum_date'>Le "+Memorandum.get_structured_date(memorandum)+".</span> "
      memorandum_title = "<span class='memorandum_title'>"+memorandum.title+"</span> : "
      memorandum_size = 400
      memorandum_subject_size = memorandum_size - (memorandum_signature.size + memorandum_date.size + memorandum_title.size) 
      memorandum_subject = "<span class='memorandum_subject'>"+truncate(memorandum.subject, memorandum_subject_size)+".</span> "
      display = ( max_memorandums == 1 ? "inline" : "none" )
      formated_memorandum << "<div id='banner_memorandum_#{memorandum.id}' class='memorandums position_#{max_memorandums}' style='display: #{display};'>"
      formated_memorandum << memorandum_date
      formated_memorandum << memorandum_title
      formated_memorandum << memorandum_subject
      formated_memorandum << memorandum_signature+"</div>"
  end
  
  def contextual_search()
    html= "<p>"
    
    # Small hack to catch the model name with the controller object
    choose_model = controller.to_s.split("<")[1].split(":")[0].gsub(/Controller/,"").singularize unless controller.nil?
    
    html+= "<input type='hidden' name=\"contextual_search[model]\" value='#{choose_model}' />"
    html+= text_field_tag "contextual_search[value]",'Rechercher',:id => 'input_search',:onfocus=>"if(this.value=='Rechercher'){this.value='';}", :onblur=>"if(this.value==\"\"){this.value='Rechercher';}", :style=>"color:grey;"
    html+= "<button type=\"submit\" class=\"contextual_search_button\"></button>"
    html+= link_to( "Recherche avancée",{ :controller => 'search', :method => 'put', :choosen_model =>controller},{:class => 'help'})
    html+="</p>"
  end
  
  private
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
    
    def current_menu
      #OPTIMIZE remove the reference to step (which comes from sales feature) and override this method in the feature sales to add the step notion
      step = controller.current_order_step if controller.respond_to?("current_order_step")
      menu = step || controller.controller_name
      Menu.find_by_name(menu) or raise "The controller '#{controller.controller_name}' should have a menu with the same name"
    end
end