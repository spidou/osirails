class FeatureManager
  attr_accessor :feature
  
  cattr_accessor :all_menus, :menus_to_check
  @@all_menus      ||= []
  @@menus_to_check ||= []
  
  def initialize yaml_config, plugin, config, path
    @name           = yaml_config['name']           || plugin
    @title          = yaml_config['title']          || ""
    @version        = yaml_config['version']        || ""
    @dependencies   = yaml_config['dependencies']   || {}
    @conflicts      = yaml_config['conflicts']      || {}
    @menus          = yaml_config['menus']          || {}
    @configurations = yaml_config['configurations'] || {}
    
    @config         = config
    @path           = path
    
    # puts "> #{@name} > initialize"
    
    plugin ? load_plugin : load_feature
  end
  
  def load_feature
    load_all
  end
  
  def load_plugin
    # load paths first
    load_paths
    
    load_menus(@menus)
    
    insert_menus_in_database
  end
  
  private
    def load_all
      # create the feature if not exists already in the database
      create_feature_if_necessary
      
      # stop here if the feature is not marked as activated
      return unless @feature.activated
      
      # load paths first
      load_paths
      
      load_dependencies
      
      load_conflicts
      
      load_configurations
      
      load_menus(@menus)
      
      insert_menus_in_database
    end
    
    def create_feature_if_necessary
      @feature = Feature.find_by_name_and_version(@name, @version) || Feature.new(:name => @name, :version => @version, :title => @title)
      if ( @feature.new_record? and @feature.activate_by_default? ) or @feature.kernel_feature?
        @feature.activated = true unless @feature.activated
        @feature.installed = true unless @feature.installed
        @feature.save if @feature.changed?
      end
    end
    
    # load all configurations key and value in the database
    # and launch the ConfigurationManager to refresh its methods
    def load_configurations
      @configurations.each_pair do |key, value|
        Configuration.create(:name => "#{@name.downcase}_#{key}", :value => value["value"], :description => value["description"]) unless Configuration.find_by_name("#{@name.downcase}_#{key}")
      end
      ConfigurationManager.reload_methods! unless @configurations.empty?
    end
    
    def load_dependencies
      dependencies_hash = []
      @dependencies.each_pair do |key, value|
        dependencies_hash << { :name => key, :version => value }
      end
      @feature.update_attribute('dependencies', dependencies_hash)
    end
    
    def load_conflicts
      conflicts_hash = []
      @conflicts.each_pair do |key, value|
        conflicts_hash << { :name => key, :version => value }
      end
      @feature.update_attribute('conflicts', conflicts_hash)
    end
    
    def load_menus(menus, parent_name = nil)
      menus.each_pair do |menu, options|
        options ||= {}
        @@all_menus << { :name => menu, :title => options["title"], :description => options["description"], :parent => parent_name, :position => options["position"], :hidden => options["hidden"], :separator => options["separator"] }
        load_menus(options["children"], menu) unless options["children"].nil?
      end
    end
    
    def insert_menus_in_database
      @@all_menus.each do |menu_array|
        parent_menu = Menu.find_by_name(menu_array[:parent])
        feature_id = @feature.nil? ? parent_menu.nil? ? nil : parent_menu.feature_id : @feature.id # "parent_menu.feature.id permits to get the feature id of the parent menu, but actually that works only if the feature of the parent menu is loaded before the current feature
        parent_menu_id = parent_menu.nil? ? nil : parent_menu.id

        # unless menu already exist
        unless current_menu = Menu.find_by_name(menu_array[:name])
          unless (m = Menu.create(:title => menu_array[:title], :description => menu_array[:description], :name => menu_array[:name], :parent_id => parent_menu_id, :feature_id => feature_id, :hidden => menu_array[:hidden]))
            puts "The feature #{name} wants to instanciate the menu #{m.name}, but it exists already. You can change the order in which features are loaded in environment.rb file by changing the 'config.plugins' array"
          else
            # if a position is defined into the yaml use it else put 0 (to identify later menus without position)
            m.position = menu_array[:position].nil? ? 0 : menu_array[:position]
            m.save
            @@menus_to_check << m.id  # add the menu with position into menus_to_check to check his position with all his siblings'one
          end
        else
          # this block test if a menu isn't define with two different parent in many config file
          @@all_menus.each do |menu_test|
            if menu_test[:name] == menu_array[:name]
              if (!menu_test[:position].nil? and !menu_array[:position].nil?) and (menu_test[:position] != menu_array[:position])
                puts "A Position conflict occured with menu '#{menu_array[:name]}'"
              end
              if menu_test[:parent] != menu_array[:parent]
                raise "Double Declaration menu : a parent conflict occured with menu '#{menu_array[:name]}' in file '#{path}/config.yml'"
              end
            end
          end

          # if menu option is not present in database
          if !menu_array[:title].nil? and current_menu.title.nil?
            current_menu.title = menu_array[:title]
            current_menu.insert_at(menu_array[:position]) unless menu_array[:position].nil?
          end
          current_menu.description = menu_array[:description] if !menu_array[:description].nil? and current_menu.description.nil?

          current_menu.save
        end
      end
    end
    
    def load_paths
      $activated_features_path << @path
      
      # load models, controllers and helpers
      %w{ models controllers helpers }.each do |dir|
        dir_path = File.join(@path, 'app', dir)
        $LOAD_PATH << dir_path
        ActiveSupport::Dependencies.load_paths << dir_path
        @config.controller_paths << dir_path
        ActiveSupport::Dependencies.load_once_paths.delete(dir_path) # in development mode, this permits to avoid restart the server after any modifications on these paths (to confirm)
      end

      # load views
      ActionController::Base.append_view_path(File.join(@path, 'app', 'views'))
      
      # load overrides.rb file
      override_path = File.join(@path, 'overrides.rb')
      require override_path if File.exist?(override_path)
      
      # load i18n feature files
      I18n.load_path += Dir[ File.join(@path, 'lib', 'locale', '*.{rb,yml}') ]
    end

    def verify_attribute_type(attr_class, type)
      case attr_class
        when String
          return 1 unless type=="string"
        when Date
          return 1 unless type=="date"
        when DateTime
          return 1 unless type=="date"
        when Time
          return 1 unless type=="date"
        else
          return 1 unless type=="number"
      end
      return 0
    end

    def verify_sub_resources(hash,error_message)
      hash.each_pair do |sub_attribute,value|
        if value.instance_of?(Hash)
          value.each_pair do |sub_attribute2,value2|
            if value2.instance_of?(Hash)
              return verify_sub_resources(value2,error_message) unless verify_sub_resources(value2,error_message).blank?
            else
              return "#{ error_message } the attribute '#{ sub_attribute2 }' is incorrect for '#{ sub_attribute }'!" unless sub_attribute.constantize.new.respond_to?(sub_attribute2)
            end
          end
        else
          return "#{ error_message } missing attribute type or sub attributes hash for  '#{ sub_attribute }' "
        end
      end
      return ""
    end
end
