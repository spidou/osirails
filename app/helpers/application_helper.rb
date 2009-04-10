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
      User.find(session[:user_id])
    rescue
      return false
    end
  end
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.activated.each do |m|
      selected = ( menu == m || menu.ancestors.include?(m) ? "class=\"selected\"" : "")
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
      first = main_menu.children.activated.first == m ? "id=\"menu_horizontal_first\"": "" #detect if is the first element
      selected = ( ( menu == m or menu.ancestors.include?(m) ) ? "class=\"selected\"" : "") #detect if the element is selected
      html << link_to("<span title=\"#{m.description}\" #{selected} #{first} class=\"disabled\">#{m.title}</span>", "#") if m.can_list?(current_user) and !m.can_view?(current_user)
      html << link_to("<span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span>", url_for_menu(m)) if m.can_list?(current_user) and m.can_view?(current_user)
    end
    if html.empty?
      javascript_tag "window.onload = function() { $('empty').style.display='none' }"
    else
      html.reverse.to_s
    end
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
  
  #TODO remove that for good!
  def display_memorandums
    ""
  end
  
  def display_welcome_message
    "Bienvenue, " + current_user.username
  end
  
  def display_date_time
    day = DateTime.now.strftime("%A").downcase
    DateTime.now.strftime("Nous sommes le #{day} %d %B %Y, il est %H:%M")
  end
  
  def display_footer
    society_name  = content_tag :span, ConfigurationManager.admin_society_identity_configuration_name
    siret         = content_tag :span, ConfigurationManager.admin_society_identity_configuration_siret
    address       = content_tag :span, "#{ConfigurationManager.admin_society_identity_configuration_address_first_line} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_second_line} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_zip} \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_town} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_country}"
    phone         = content_tag :span, ConfigurationManager.admin_society_identity_configuration_phone
    fax           = content_tag :span, ConfigurationManager.admin_society_identity_configuration_fax
    "#{society_name} SIRET : #{siret} TEL : #{phone} FAX : #{fax} <br/> ADRESSE : #{address}"
  end
  
  def contextual_search()
    html= "<p>"
    
    model_for_search = controller.controller_name.singularize.camelize
    
    html+= "<input type='hidden' name=\"contextual_search[model]\" value='#{model_for_search}' />"
    html+= text_field_tag "contextual_search[value]",'Rechercher',:id => 'input_search',:onfocus=>"if(this.value=='Rechercher'){this.value='';}", :onblur=>"if(this.value==\"\"){this.value='Rechercher';}", :style=>"color:grey;"
    html+= "<button type=\"submit\" class=\"contextual_search_button\"></button>"
    html+= link_to( "Recherche avancée", search_path(:choosen_model => model_for_search), :class => 'help')
    html+="</p>"
  end
  
  # This method permit to point out if a required local variable hasn't been passed (or with a nil object) with the 'render :partial' call
  # 
  # Example 1 :
  # in edit.html.erb
  # <%= render :partial => @user %>
  # 
  # in _user.html.erb
  # <% require_locals my_missing_local %> # => raise an error
  # 
  # Example 2 :
  # in new.html.erb
  # <%= render :partial => @user, :locals => { :my_local => my_local } %>
  # 
  # in _user.html.erb
  # <% require_locals my_local %> # => no error
  # 
  # 
  # The method accepts many variable at time :
  # <% require_locals local1, local2, local3 %>
  #
  def require_locals *locals
    locals.each do |local|
      raise "The partial you called requires at least one local variable. Please verify if the(se) local(s) is/are correctly referenced when you call your render :partial" if local.nil?
    end
  end
  
  # Returns - true if the current page is an editable page (add/edit)
  #         - false if the current page is an view page (show)
  #
  def is_form_view?
     is_edit_view? or is_new_view?
  end
  
  def is_new_view?
    params[:action] == "new" or request.post?
  end
  
  def is_edit_view?
    params[:action] == "edit" or request.put?
  end
  
#  def can_edit?(object)
#    test_permission("edit", object)
#  end
#  
#  def can_add?(object)
#    test_permission("add", object)
#  end
  
  begin
    ## dynamic methods generated with the menus object
    #  
    #  Example :
    #  menus :             users, groups, thirds
    #  generated methods : menu_users, menu_groups, menu_thirds
    Menu.find(:all, :conditions => [ "name IS NOT NULL" ]).each do |menu|
      define_method("menu_#{menu.name}") do
        Menu.find_by_name(menu.name)
      end
    end
  rescue ActiveRecord::StatementInvalid, Mysql::Error => e
    error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
    RAKE_TASK ? puts(error) : raise(error)
  end
  
  def secondary_menu(title, &block)
    raise ArgumentError, "Missing block" unless block_given?
    
    html = content_tag(:h1, title)
    html += "<ul>"
    capture(&block).split("\n").each do |line|
      next if line.blank?
      html += content_tag :li, line
    end
    html += "</ul>"
    content_for(:secondary_menu) {html}
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
    
#    def test_permission(method, object)
#      controller_name = object.class.name.downcase.pluralize
#      begin
#        send("menu_#{controller_name}").send("can_#{method}?", current_user)
#      rescue NoMethodError => e
#        real_controller_name = "#{controller_name}_controller".camelize
#        raise "You may create a controller called '#{real_controller_name}' and create a menu entry in the 'config.yml' file of the corresponding feature. #{e.message}"
#      end
#    end
end
