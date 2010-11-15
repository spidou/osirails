# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def file_upload
    file_field 'upload', 'datafile'
  end
  
  def display_flash
    html = ""
    flash.each_pair do |key, value|
      html << "<div class=\"flash_#{key}\"><span>#{value}</span></div>"
    end
    html.empty? ? "" : "<div class=\"flash_container\">#{html}</div>"
  end
  
  def current_user
    @current_user ||= User.find_by_id(session[:user_id], :joins => [:roles])
  end
  
  def display_version
    if !Rails.env.production? or params[:debug]
      "<span class=\"version\">v#{Osirails::VERSION}<br/>#{Rails.env}</span>"
    end
  end
  
  def display_menu
    menu = current_menu
    html = ""
    html << display_menu_entries(menu)
    html
  end
  
  #TODO remove that for good!
  def display_memorandums
    ""
  end
  
  def display_welcome_message
    "#{t 'welcome'}, #{current_user.username}"
  end
      
  def include_calendar_headers_tags(language = "en")
    lang_file = "calendar/lang/calendar-#{language}.js"
    lang_file = "calendar/lang/calendar-#{language[0..1]}.js" unless File.exists?(File.join(RAILS_ROOT,'public','javascripts',lang_file))
    lang_file = "calendar/lang/calendar-en.js" unless File.exists?(File.join(RAILS_ROOT,'public','javascripts',lang_file))
    javascript_include_tag("calendar/calendar.js") + "\n" + 
    javascript_include_tag(lang_file) + "\n" + 
    javascript_include_tag("calendar/calendar-setup.js") + "\n" +
    stylesheet_link_tag_with_theme_support("dhtml_calendar.css") + "\n" + 
    stylesheet_link_tag_with_theme_support("dhtml_calendar_style.css")
  end
  
  def daynames_and_monthnames_retrieval
      html = "<script type=\"text/javascript\">"
      html << "var rubyDayNames = new Array();"
      0.upto(6){|day|
        html << "rubyDayNames[" + day.to_s + "] = \"" + t('date.day_names')[day] + "\";"
      }
      html << "</script>"
      
      html << "<script type=\"text/javascript\">"
      html << "var rubyMonthNames = new Array();"
      0.upto(11){|month|
        html << "rubyMonthNames[" + month.to_s + "] = \"" + t('date.month_names')[month + 1] + "\";"
      }
      html << "</script>"
      
      html << "<script type=\"text/javascript\">"
      html << "var rubyTime = \"" + Time.zone.now.strftime("%Y %m %d %H:%M:%S") + "\" ;"
      html << "</script>"
  end
  
  def display_date_time
    now = Time.zone.now
    html =  "Nous sommes le "
    html << "<span id='banner_date'>"
    html << l(now.to_date, :format => :long_ordinal)
    html << "</span>"
    html << ", il est "
    html << "<span id='banner_time'>"
    html << l(now, :format => :time)
    html << "</span>"
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
    params[:action] == "edit" or params[:action].ends_with?("_form") or request.put?
  end
  
  def is_show_view?
    params[:action] == "show"
  end
  
  #begin
  #  ## dynamic methods generated with the menus object
  #  #  
  #  #  Example :
  #  #  menus :             users, groups, thirds
  #  #  generated methods : menu_users, menu_groups, menu_thirds
  #  Menu.find(:all, :conditions => [ "name IS NOT NULL" ]).each do |menu|
  #    define_method("menu_#{menu.name}") do
  #      Menu.find_by_name(menu.name)
  #    end
  #  end
  #rescue ActiveRecord::StatementInvalid, Mysql::Error => e
  #  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  #  RAKE_TASK ? puts(error) : raise(error)
  #end
  
  # add item in the given section of the contextual menu
  #
  # Examples :
  #   # => add single item in the section 'section_name'
  #   add_contextual_menu_item(:section_name, item)
  #   
  #   # => add multiple items
  #   add_contextual_menu_item(:section_name, item1, item2)
  #
  #   # => add single or multiple items with block
  #   add_contextual_menu_item(:section_name) do
  #     item
  #   end
  #
  # Default behaviour is to create a <ul></ul> element under the section
  # and to create <li></li> for each line of the block (so for each items).
  # You can override this behaviour by passing true in second argument
  #
  # Examples :
  #   add_contextual_menu_item(:section_name, :force_not_list => true, item)
  #
  #   add_contextual_menu_item(:section_name, :force_not_list => true) do
  #     item
  #   end
  #
  # You can manage to insert your item at a given position
  #
  # Examples :
  #   add_contextual_menu_item(:section_name, :position => :first, :item)
  #   add_contextual_menu_item(:section_name, :position => :first) do
  #     item
  #   end
  #   add_contextual_menu_item(:section_name, :position => :last, :item) 
  #   add_contextual_menu_item(:section_name, :position => 2, :item)
  #
  def add_contextual_menu_item(section, *args, &block)
    options = (args.first.is_a?(Hash) ? args.shift : {:force_not_list => false, :position => :last})
    items   = block_given? ? capture(&block).split("\n") : args.dup
    
    items.each do |item|
      @contextual_menu.add_item(section, options[:force_not_list], options[:position], item)
    end
  end
  
  def display_contextual_menu
    render :partial => 'share/contextual_menu' unless @contextual_menu.sections.empty?
  end
  
  def content_page_class
    'with_pinned_menu' if cookies[:pin_status] == 'pinned' and !@contextual_menu.sections.empty?
  end
  
  def display_contextual_menu_content
    html = ''
    @contextual_menu.sections.each do |section|
      next if section.items.empty?
      html << content_tag(:h1, section.to_s)
      html << "<ul>" if section.list?
      section.items.each do |item|
        if section.list?
          html << content_tag(:li, item.content)
        else
          html << item.content
        end
      end
      html << '</ul>' if section.list?
    end
    
    html
  end
  
  def generate_random_id(length = 8)
    chars = ['A'..'Z', 'a'..'z', '0'..'9'].map{|r|r.to_a}.flatten
    Array.new(length).map{chars[rand(chars.size)]}.join
  end
  
  METHOD_MATCH = /_link$/
  # Creates dynamic helpers to generate standard links in all page
  # These dynamic helpers are based on RESTful path methods generated from routes
  # 
  # Methods must end by "_link"
  # 
  # ==== Examples
  #   users_link                          # model => user        | action => list   | method called => users_path
  #   new_group_link                      # model => group       | action => add    | method called => new_group_path
  #   user_link(@user)                    # model => user        | action => view   | method called => user_path(@user)
  #   edit_user_link(@user)               # model => user        | action => edit   | method called => edit_user(@user)
  #   delete_geat_model_link(@geat_model) # model => geat_model  | action => delete | method called => link_to("Delete", @user, { :method => :delete, :confirm => "Are you sure?"})
  #
  # ==== Arguments
  # For the actions +list+ and +add+, only one parameter is allowed
  # 
  # For the actions +view+, +edit+, +delete+, the first parameter (+object+) is required, and a second parameter is allowed
  # 
  # The first parameter (for +list+ and +add+) and the second parameter (for +view+, +edit+ and +delete+) must be a Hash
  # 
  # <tt>:image_tag</tt> permits to define a custom image tag for the link
  #   <%= user_link(@user, :image_tag => image_tag("view.png") ) %>
  # 
  # <tt>:link_text</tt> permits to define a custom value for the link label
  #   <%= new_user_link( :link_text => "Add a user" ) %>
  # 
  def method_missing(method, *args)
    # did somebody try to use a dynamic link helper?
    return super(method, *args) unless method.to_s =~ METHOD_MATCH
    
    # retrieve objects and options hash into args array
		args_objects = []
    options = {}
		args.each do |arg|
		  if arg.is_a?(Hash)
				options.merge!(arg)
			elsif arg.class.ancestors.include?(ActiveRecord::Base)
        args_objects << arg
      else
        raise ArgumentError, "#{method} expected 'hash' or 'ActiveRecord object' parameter but received #{arg}:#{arg.class}"
      end
		end
    
    # retrieve infos about model and path from the given method
    method_infos              = dynamic_link_catcher_retrieve_method_infos(method.to_s, args_objects)
    path_name                 = method_infos[:path_name]
    model_name                = method_infos[:model_name]
    expected_objects          = method_infos[:expected_objects]
    
    # check if the method called is well-formed
    dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)

    # define what is the permission method name according to the given method
    if model_name != model_name.singularize       # users
      permission_name = :list
      icon_name = :index
      model_name = model_name.singularize
    
    elsif path_name.match(/^(formatted_)?new_/)   # new_user    | formatted_new_user
      permission_name = :add
      icon_name = :new
    
    elsif path_name.match(/^(formatted_)?edit_/)  # edit_user   | formatted_edit_user
      permission_name = :edit
      icon_name = :edit
    
    elsif path_name.match(/^delete_/)             # delete_user
      permission_name = :delete
      icon_name = :delete
      path_name = path_name.gsub("delete_","")    # the prefix "delete_" is removed because it doesn't match to any path method name

    elsif path_name.match(/^(formatted_)?/)       # user       | formatted_user  | great_model |  formatted_great_model
      permission_name = :view
      icon_name = :show
    
    else
      raise NameError, "'#{method}' seems to be a dynamic helper link, but it has an unexpected form. Maybe you misspelled it? "
    end
    
    # define the corresponding model, and check the permissions
    model                     = model_name.camelize.constantize # this will raise a NameError Exception if the constant is not defined
	  has_model_permission      = model.respond_to?("business_object?") ? model.send("can_#{permission_name}?", current_user) : true
	  has_controller_permission = controller.current_menu.send("can_access?", current_user)
    
    # default html_options
    html_options = { 'data-icon' => icon_name }.merge(options.delete(:html_options) || {})
    
    # default options
	  options = { :link_text    => default_title = dynamic_link_catcher_default_link_text(permission_name, model_name.tableize),
	              :image_tag    => nil,
                :options      => {},
                :html_options => html_options
              }.merge(options)
    
    # return the correspondong link_to tag if permissions are allowing that!
    if has_controller_permission and has_model_permission
		  link_content = "#{options[:image_tag]} #{options[:link_text]}"
      
      # eval url-genrator method : user_path(1) => '/users/1' , edit_user_group_path(1,1) => '/users/1/groups/1/edit'
      complete_path_method = "#{path_name}_path("
      args_objects.each_index do |i|
        complete_path_method << ", " unless i == 0
        complete_path_method << "args_objects[#{i}]"
      end
      complete_path_method << "#{"," unless args_objects.empty?} options[:options]" unless options[:options].empty?
      complete_path_method << ")"
      link_url = eval(complete_path_method)
      
      options[:html_options] = options[:html_options].merge({ :method => :delete, :confirm => "Are you sure?" }) if permission_name == :delete
      
      return link_to( link_content, link_url, options[:html_options] )
    else
      return nil
    end
  end
  
  def respond_to?(method, include_private = false)
    if method.to_s =~ METHOD_MATCH
      return true
    else
      return super(method)
    end
  end
  
  private    
    # check if all objects passed into args correspond to the helper name
    #
    # ==== Examples
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @user, @group] )  # => no raise
    #
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @user ] )         # => raise exception
    #
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @group, @user ] ) # => raise exception
    #
    def dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)
      objects = args_objects.collect{ |o| o.class.to_s.tableize.singularize }
      
      expected_objects.each_with_index do |expected_object, index|
        unless objects[index] == expected_object
          raise ArgumentError, "expected a '#{expected_object.titleize}' object instance, but received a '#{objects[index].titleize}' one instead"
        end
      end
    end

    # retrives the model name and the method name from the called method
    # 
    # ==== Examples
    #   dynamic_link_catcher_retrieve_method_infos("edit_user_link")
    #   # => { :model_name => "user", :path_name => "edit_user" }
    # 
    #   dynamic_link_catcher_retrieve_method_infos("new_great_model_link")
    #   # => { :model_name => "great_model", :path_name => "new_great_model" }
    #
    #   dynamic_link_catcher_retrieve_method_infos("new_great_model_sub_model_link")
    #   # => { :model_name => "sub_model", :path_name => "new_great_model_sub_model" }
    # 
    def dynamic_link_catcher_retrieve_method_infos(method, args_objects)
      path = method.split("_")   # "formatted_new_great_model_link" => [ "formatted", "new", "great", "model", "link" ]
      path.pop 
      models = path.reject{ |s| %W{ formatted new edit delete }.include?(s) } # [ "formatted", "new", "great", "model" ] => [ "great", "model" ]
      infos = dynamic_link_catcher_retrieve_resources_model_infos(models, args_objects)
      model_name = infos[:model]
      nested_resources = infos[:nested_resources]
      
      { :model_name => model_name, :path_name => path.join("_"), :expected_objects => nested_resources}
    end
    
    # retrieve infos about the nested resources and the model which are implied in the path method
    #
    # ==== Examples
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user" ], [ @user ] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user" ], [] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user", "group", "type" ], [ @user, @group_type ] )
    #   # =>  { :nested_resources => [ "user" ], :model => "group_type"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( ["user", "role", "group", "type" ], [ @user, @role, @group_type ])
    #   # =>  { :nested_resources => [ "user", "role" ], :model =>"group_type"}
    def dynamic_link_catcher_retrieve_resources_model_infos(models, args_objects)
      original_path_name = models.join("_") + "_path"
      models = models.join("_")
      args_class_names = args_objects.collect{ |o| o.class.to_s.tableize.singularize }
      
      args_class_names.each do |class_name|
        if models.include?(class_name)
          models = models.gsub("#{class_name}_","")
        else
          raise "the parameter object '#{class_name}' doesn't match to the model specified in the called method '#{original_path_name}'"
        end
      end
      args_class_names.delete(models)
      
      return { :nested_resources => args_class_names, :model => models}
    end
    
    # returns a readable link text according to the given method and model
    # 
    # ==== Examples
	  #   dynamic_link_catcher_default_link_text(:edit, "user")
	  #   # => "Edit current user"
	  # 
	  #   dynamic_link_catcher_default_link_text(:add, "great_model")
    #   # => "New great model"
    # 
    #   dynamic_link_catcher_default_link_text(:list, "group")
    #   # => "List all groups"
    # 
    def dynamic_link_catcher_default_link_text(method_name, model_name)
      default_text = { :list    => "Voir tous",#"List all ",
                       :view    => "Voir",#"View this ",
										   :add     => "Nouveau",#"New ",
										   :edit    => "Modifier",#"Edit this ",
										   :delete  => "Supprimer" }#"Delete this " }

      result = default_text[method_name] #+ model_name.gsub("_"," ")
      result = result.singularize unless method_name == :list
      return result
    end
    
    def url_for_menu(menu)
      # OPTIMIZE optimize this IF block code
      if menu.name
        build_menu_path(menu) || url_for(:controller => menu.name)
      else
        unless menu.content.nil?
          url_for(:controller => "contents", :action => "show", :id => menu.content.id)
        else
          return
        end
      end
    end
    
    def build_menu_path(menu, child_path = nil)
      if child_path
        path = menu.name.singularize + "_#{child_path}"
      else
        path = menu.name
      end
      
      if self.respond_to?("#{path}_path")
        self.send("#{path}_path")
      elsif menu.parent
        build_menu_path(menu.parent, path)
      else
        false
      end
    end
    
    def current_menu
      menu = controller.controller_name
      Menu.find_by_name(menu) or raise "The controller '#{menu}' should have a menu with the same name"
    end
    
    def display_menu_entries(current)
      real_current_menu = current_menu
      output = ""
      
      if current.parent
        output << display_menu_entries(current.parent)
        siblings = Menu.find_by_parent_id(current.parent_id).self_and_siblings.activated.select{|m|m.can_access?(current_user)}
      else
        siblings = Menu.mains.activated.select{|m|m.can_access?(current_user)}
      end
      
      more_link = real_current_menu == current ? '' : link_to(content_tag(:em, 'More'), '#more', :class => 'nav_more')
      
      if real_current_menu.parent
        unless current.parent
          output << content_tag(:h4, link_to('Accueil', '/') + more_link, :title => "Accueil")
        else
          h4_options = real_current_menu == current ? { :class => 'nav_current' } : {}
          url = url_for_menu(current.parent)
          output << content_tag(:h4, ( url.nil? ? current.parent.title : link_to(current.parent.title, url, :title => current.parent.description) ) + more_link, h4_options)
        end
      end
      output << "<ul#{' class="nav_top"' unless real_current_menu == current}>"
      siblings.each do |menu|
        li_options = ( menu == current or menu.ancestors.include?(current) ) ? { :class => 'selected' } : {}
        output << display_menu_entry(menu, li_options)
      end
      output << "</ul>"
    end
    
    def display_menu_entry(menu, li_options)
      return "" if (url = url_for_menu(menu)).nil?
      unless menu.separator.blank?
        li_options.merge!({:class => "#{li_options[:class]} #{menu.separator}_separator"}) if ( menu.separator == 'before' and menu.can_move_up? ) or ( menu.separator == 'after' and menu.can_move_down? )
      end
      content_tag(:li, link_to(menu.title, url, :title => menu.description), li_options)
    end
end
