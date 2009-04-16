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
    # Creates dynamic helpers to generate standard links in all page
    # These dynamic helpers are based on RESTful path methods generated from routes
    # 
    # Methods must start end by "_link"
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
    #   <%= user_link(@user, :image_tag => image_tag("/images/view.png") ) %>
    # 
    # <tt>:link_text</tt> permits to define a custom value for the link label
    #   <%= new_user_link( :link_text => "Add a user" ) %>
    # 
    def method_missing_with_dynamic_link_catcher(method, *args)
      # did somebody tried to use a dynamic link helper?
      unless method.to_s.match(/_link$/)
        if block_given?
          return method_missing_without_dynamic_link_catcher(method, *args) { |*a| yield(*a) }
        else
          return method_missing_without_dynamic_link_catcher(method, *args) 
        end
      end
      
      # retrieve objects and options hash into args array
			args_objects = []
      options = {}
			args.each do |arg|
				arg.is_a?(Hash) ? options = arg : args_objects << arg 
			end

      # retrieve infos about model and path from the given method
      method_infos              = dynamic_link_catcher_retrieve_method_infos(method.to_s, args_objects)
      path_name                 = method_infos[:path_name]
      model_name                = method_infos[:model_name]
      expected_objects          = method_infos[:expected_objects]

      # define what is the permission method name according to the given method
      if model_name != model_name.singularize         # users
        permission_name = :list
        model_name = model_name.singularize
      
      elsif path_name.match(/^(formatted_)?new_/)   # new_user    | formatted_new_user
        permission_name = :add
      
      elsif path_name.match(/^(formatted_)?edit_/)  # edit_user   | formatted_edit_user
        permission_name = :edit
      
      elsif path_name.match(/^delete_/)             # delete_user
        permission_name = :delete
  
      elsif path_name.match(/^(formatted_)?/)        # user       | formatted_user  | great_model |  formatted_great_model
        permission_name = :view
      
      else
        raise NameError, "'#{method}'seems to be a dynamic helper link, but it has an unexpected form. Maybe you misspelled it? "
      end
      
      # define the corresponding model, and check the permissions
      model                     = model_name.camelize.constantize # this will raise a NameError Exception if the constant is not defined
		  has_model_permission      = model.respond_to?("business_object?") ? model.send("can_#{permission_name}?", current_user) : true
		  has_controller_permission = controller.send("can_#{permission_name}?", current_user)
      
      # check if the method called is well-formed
      dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)
      raise ArgumentError, 'parameter hash expected' unless options.is_a?(Hash)
      
      # default options
		  options = { :link_text   => default_title = dynamic_link_catcher_default_link_text(permission_name, model_name.tableize),
		              :image_tag   => image_tag( "/images/#{permission_name}_16x16.png",
		                                         :title => default_title,
		                                         :alt => default_title )
	              }.merge(options)
	    
	    # return the correspondong link_to tag if permissions are allowing that!
      if has_controller_permission and has_model_permission
			  link_content = "#{options[:image_tag]} #{options[:link_text]}"

        case permission_name
        when :delete
          # TODO make works nested ressources when deleting 
          return link_to( link_content, args_objects.first, { :method => :delete, :confirm => "Are you sure?" } )
        else
          # eval url-genrator method : user_path(1) => '/users/1' , edit_user_group_path(1,1) => '/users/1/groups/1/edit'
          tmp = "#{path_name}_path("
          args_objects.each_index do |i|
            tmp << "," unless i == 0
            tmp << "args_objects[#{i}]"
          end
          tmp << ")"
          url = eval(tmp)
        end
        puts "> #{url}"
        return link_to( link_content, url )
      end
    end
    
    alias_method_chain :method_missing, :dynamic_link_catcher
    
    # retrieve nested ressource
    #
    # ==== Example
    #   nested_ressources( [ "user" ], [ @user ] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   nested_ressources( [ "user" ], [] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   nested_ressources( [ "user", "group", "type" ], [ @user, @group_type ] )
    #   # =>  { :nested_resources => [ "user" ], :model => "group_type"}
    #
    #   nested_ressources( ["user", "role", "group", "type" ], [ @user, @role, @group_type ])
    #   # =>  { :nested_resources => [ "user", "role" ], :model =>"group_type"}
    def nested_ressources(models, args_objects)
      nested_resources = []
      args_objects.each do |o|
        nested_resources << o.class.to_s.tableize.singularize      
      end
      model = models.join("_")
      
      nested_resources.each  do |nested_resource|
        if model.include?(nested_resource)
          model = model.gsub("#{nested_resource}_","")
        else
          raise "The nested resource '#{nested_resource}' doesn't match to the method name" 
        end
      end
      nested_resources.delete(model)
      puts ">>> call nested resources => nested_resources : #{nested_resources.inspect} | model : #{model.inspect}"
      return { :nested_resources => nested_resources, :model => model}
    end

    # check if all objects passed into args correspond to the helper name
    #
    # raise an ArgumentError error type if one the 'expected_object' is missed into 'args_objects'
    # ==== Exmaple
    #   dynamic_link_catcher_check_arguments_objects(["employee","job"], [Employee.new] )
    #   # => raise "expected object or id of Job class"
    def dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)
      objects = Array.new      
      args_objects.each do |o|
        objects << o.class.to_s.tableize.singularize      
      end

      expected_objects.each do |o|
        raise ArgumentError, "expected object or id of #{o.titleize} class" unless objects.join("_").singularize.include?(o)      
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
      infos = method.split("_")   # "formatted_new_great_model_link" => [ "formatted", "new", "great", "model", "link" ]
      infos.pop 
      models = infos.reject{ |s| %W{ formatted new edit delete }.include?(s) } # [ "formatted", "new", "great", "model" ] => [ "great", "model" ]
      t = nested_ressources(models, args_objects) 
      model_name = t[:model]
      models = t[:nested_resources]      

      { :model_name => model_name, :path_name => infos.join("_"), :expected_objects => models}
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
      default_text = { :list    => "List all ",
                       :view    => "View this ",
										   :add     => "New ",
										   :edit    => "Edit this ",
										   :delete  => "Delete this " }

      result = default_text[method_name] + model_name.gsub("_"," ")
      result = result.singularize unless method_name == :list
      return result
    end
   ###########################################""""
    # "employee_premium" => premium, or "employee_number_type" => number_type
    def dynamic_link_catcher_retrieve_nested_ressource(models, args_models)

      ressources = models.split("_").last
      return ressources.last




      
      return models unless models.include?(prime_ressource) # that mean there's not nested ressources 


			args_models.each do |model|
				raise "you missed an object or id of #{model.class.to_s.tableize.singularize} class" if !ressources.include?(model.class.to_s.tableize.singularize) and model != nested_ressource
			end

      
      result = prime_ressource
      # OPTIMIZE use .singularized_table_name() in place of .to_s.tableize.singularize
      # ressource = args_models.first.to_s.tableize.singularize # get the primary ressource    

      ressource = args_models.first

      ressources.each_with_index do |nested_r,i|
        nested_ressource << nested_r
        if args_models.include?(ressource) 
          if ressource.respond_to?(nested_ressource) or ressource.respond_to?(nested_ressource.pluralize)
            raise "nr: "+nested_ressource+" r:"+ressource.inspect
            ressource = args_models[i] 
            result = nested_ressource
            nested_ressource = ""
          else
            nested_ressource << "_"
          end
        else
          nested_ressource << "_"
        end   
      end
      #raise "r:"+ressources.inspect+" p:"+prime_ressource+" n:"+result
      return result

      raise "#{nested_ressource} doesn't exist please verify the name" 
    end
############################################## 
#    # creates dynamic helpers to generate standard buttons in all page
#    # these dynamic helpers are generated according to the +model+ and +action+ given in the method name
#    # 
#    # Methods must start by "show_" and end by "_button"
#    # The before last word represents the +action+ to do (list, add, view, edit or delete)
#    # The set of words between the first underscore and the before-before last underscore represents the +model+
#    # An +object+ must be given for the following actions : view, edit, delete
#    # 
#    # ==== Examples
#    #   show_user_list_button                       # model => user         | action => list
#    #   show_group_add_button                       # model => group        | action => add
#    #   show_user_view_button(@user)                # model => user         | action => view     | object => @user
#    #   show_user_edit_button(@user)                # model => user         | action => edit     | object => @user
#    #   show_geat_model_delete_button(@geat_model)  # model => geat_model   | action => delete   | object => @geat_model
#	  #
#	  # ==== Arguments
#	  # For the actions +list+ and +add+, only one parameter is allowed
#	  # 
#	  # For the actions +view+, +edit+, +delete+, the first parameter (+object+) is required, and a second parameter is allowed
#	  # 
#	  # The first parameter (for +list+ and +add+) and the second parameter (for +view+, +edit+ and +delete+) must be a Hash
#	  # 
#	  # <tt>:image_src</tt> permits to define a custom image source for the link
#    #   <%= show_user_list_button( :image_src => "/images/list.png" ) %>
#    #
#    # <tt>:image_title</tt> permits to define a custom image title for the link
#    #   <%= show_user_list_button( :image_title => "My Custom Title" ) %>
#    #
#    # <tt>:image_alt</tt> permits to define a custom image alternative text for the link
#    #   <%= show_user_list_button( :image_alt => "My custom alternative text" ) %>
#    # 
#    # <tt>:link_text</tt> permits to define a custom value for the link label
#    #   <%= show_user_add_button( :link_text => "Add a user" ) %>
#    # 
#	  def method_missing_with_dynamic_button_helper(method, *args)
#      # did somebody tried to use a dynamic button helper?
#      unless method.to_s.match(/^show_[a-z]*((_)[a-z]*)*_(list|view|add|edit|delete)_button$/)
#        if block_given?
#          return method_missing_without_dynamic_button_helper(method, *args) { |*a| yield(*a) }
#        else
#          return method_missing_without_dynamic_button_helper(method, *args) 
#        end
#      end
#      
#      method_infos              = dynamic_button_helper_retrieve_method_infos(method.to_s)
#      method_name               = method_infos[:method_name]
#      model_name                = method_infos[:model_name]
#      model                     = model_name.camelize.constantize # this will raise a NameError Exception if the constant is not defined
#		  has_model_permission      = model.respond_to?("can_#{method_name}?") ? model.send("can_#{method_name}?", current_user) : true
#		  has_controller_permission = controller.send("can_#{method_name}?", current_user)
#		  tableized_model_name      = model_name.tableize                      # if we use model name
#	#	  tableized_model_name      = controller.controller_name.tableize      # if we use the controller name
#		  
#		  if [:add, :list].include?(method_name)  # add, list          => 1 parameter at most (params)
#		    options = args[0] || {}
#      else                                    # view, edit, delete => 1 parameter at least, 2 parameters at most (object, params)
#        object_or_id = args[0]
#        raise ArgumentError, 'parameter object or ID expected' if object_or_id.nil?
#        options = args[1] || {}
#      end
#      
#      raise ArgumentError, 'parameter hash expected' unless options.is_a?(Hash)
#		  
#		  options = { :image_src   => "/images/#{method_name}_16x16.png",
#		              :image_title => default_title = dynamic_button_helper_default_link_text(method_name, tableized_model_name),
#		              :image_alt   => default_title,
#		              :link_text   => default_title,
#	              }.merge(options)
#
#      if has_controller_permission and has_model_permission
#			  path = { :view => "", :edit => "edit_" }
#			  content = image_tag( options[:image_src], :alt => options[:image_alt], :title => options[:image_title]) + " #{options[:link_text]}"
#        
#        case method_name
#        when :delete
#          return link_to( content, object_or_id, { :method => :delete, :confirm => "Êtes-vous sûr ?" } )
#        when :list
#          url = send("#{tableized_model_name}_path")
#        when :add
#          url = send("new_#{tableized_model_name.singularize}_path")
#        else	
#				  url = send("#{path[method_name]}#{tableized_model_name.singularize}_path", object_or_id)
#        end
#        
#        return link_to( content, url )
#      end
#    end
    
#    # retrives the model name and the method name from the called method
#    # 
#    # ==== Examples
#    #   dynamic_button_helper_retrieve_method_infos("show_user_edit_button")
#    #   # => { :model_name => "user", :method_name => "edit" }
#    # 
#    #   dynamic_button_helper_retrieve_method_infos("show_great_model_add_button")
#    #   # => { :model_name => "great_model", :method_name => "add" }
#    # 
#    def dynamic_button_helper_retrieve_method_infos(method)
#      infos = method[5...method.rindex("_button")].split("_")               # "show_great_model_edit_button" => [ "great", "model", "edit" ]
#      { :method_name => infos.pop.to_sym, :model_name => infos.join("_") }
#    end
    
#    # returns a readable link text according to the given method and model
#    # 
#    # ==== Examples
#	  #   dynamic_button_helper_default_link_text(:edit, "user")
#	  #   # => "Edit current user"
#	  # 
#	  #   dynamic_button_helper_default_link_text(:add, "great_model")
#    #   # => "New great model"
#    # 
#    #   dynamic_button_helper_default_link_text(:list, "group")
#    #   # => "List all groups"
#    # 
#    def dynamic_button_helper_default_link_text(method_name, model_name)
#      default_text = { :list    => "List all ",
#                       :view    => "View this ",
#										   :add     => "New ",
#										   :edit    => "Edit this ",
#										   :delete  => "Delete this " }
#
#      result = default_text[method_name] + model_name.gsub("_"," ")
#      result = result.singularize unless method_name == :list
#      return result
#    end
    
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
