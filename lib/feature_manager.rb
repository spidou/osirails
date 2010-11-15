require 'active_record'
require 'yaml'

class FeatureManager
  attr_accessor :feature
  
  @@initialized_once ||= false
  
  FEATURE_PATHS = Dir["#{RAILS_ROOT}/{lib,vendor}/features/*/"]
  
  cattr_accessor :loaded_feature_paths
  @@loaded_feature_paths ||= []
  
  @@ordered_feature_names ||= nil
  
  cattr_accessor :all_menus, :menus_to_check
  @@all_menus      ||= []
  @@menus_to_check ||= []
  
  def self.preload(config, path, plugin = false)
    object = self.new(config, path, plugin)
    object.load_engine
    return object
  end
  
  def self.ordered_feature_names
    @@ordered_feature_names || ( self.ordered_feature_paths && @@ordered_feature_names )
  end
  
  def self.ordered_feature_paths
    @@ordered_feature_names ||= []
    @@ordered_feature_paths ||= []
    
    FEATURE_PATHS.each do |feature_path|
      load_features_dependencies(feature_path.split('/').last)
    end
    
    @@ordered_feature_paths
  end
  
  def self.load_features_dependencies(name)
    return if @@ordered_feature_names.include?(name)
    FEATURE_PATHS.each do |feature_path|
      feature_name = feature_path.split('/').last
      next unless feature_name == name
      yaml = YAML.load(File.open(File.join(feature_path, 'config.yml')))
      unless yaml['dependencies'].nil?
        yaml['dependencies'].each do |key, val|
          load_features_dependencies(key.to_s)
        end
      end
      @@ordered_feature_names << name
      @@ordered_feature_paths << feature_path
      break
    end
  end
  
  def self.update_config_plugins(config)
    plugins = config.plugins.dup
    self.ordered_feature_names.map(&:to_sym).each do |name|
      plugins.insert(plugins.index(:all) || plugins.last, name)
    end
    config.plugins = plugins
  end
  
  def self.initialize_all_features
    return if @@initialized_once
    @@initialized_once = true
    
    FEATURE_PATHS.each do |feature_path|
      feature_name = feature_path.split("/").last
      FeatureManager.new(nil, feature_path).create_feature_if_necessary
    end
  end
  
  def initialize(config, path, plugin = false)
    FeatureManager.initialize_all_features
    
    yaml_path = File.join(path, 'config.yml')
    yaml = YAML.load(File.open(yaml_path)) rescue {}
    
    @name           = yaml['name']           || plugin
    @title          = yaml['title']          || ""
    @version        = yaml['version']        || ""
    @dependencies   = yaml['dependencies']   || {}
    @conflicts      = yaml['conflicts']      || {}
    @menus          = yaml['menus']          || {}
    @configurations = yaml['configurations'] || {}
    
    @plugin         = plugin
    @config         = config
    @path           = path
  end
  
  def load_engine
    @plugin ? load_plugin : load_feature
  end
  
  def load_feature
    return unless database_is_ready?
    
    @feature = Feature.find_by_name_and_version(@name, @version)
    
    if @feature
      if Rails.env.test?
        load_plugin if @feature.name == TESTING_FEATURE or @feature.child_dependencies.collect{ |h| h[:name] }.include?(TESTING_FEATURE)
      else
        if SEEDING_FEATURE
          load_plugin if @feature.name == SEEDING_FEATURE or @feature.child_dependencies.collect{ |h| h[:name] }.include?(SEEDING_FEATURE)
        elsif @feature.activated?
          load_plugin
        end
      end
    else
      raise "Feature '#{@name}' has not been found in the database..."
    end
  end
  
  def load_plugin
    Rails.logger.info "loading #{@name} ..."
    
    load_paths
    
    load_libs
    
    return unless database_is_ready?
    
    load_menus(@menus)
    
    insert_menus_in_database
    
    @@loaded_feature_paths << @path
  end
  
  def create_feature_if_necessary
    return unless database_is_ready?
    
    @feature = Feature.find_by_name_and_version(@name, @version) || Feature.new(:name => @name, :version => @version, :title => @title)
    @feature.installed = true if @feature.new_record?
    @feature.activated = true if @feature.new_record? and @feature.activate_by_default?
    @feature.save if @feature.changed?
    
    load_dependencies
    load_conflicts
    load_configurations
  end
  
  def database_is_ready?
    Feature.all
    return true
  rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError
    return false
  end
  
  private
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
      # load models, controllers and helpers
      %w{ lib app/models app/controllers app/helpers }.each do |dir|
        dir_path = File.join(@path, dir)
        
        $LOAD_PATH.unshift(dir_path)
        ActiveSupport::Dependencies.load_paths.unshift(dir_path)
        #ActiveSupport::Dependencies.load_once_paths.unshift(dir_path) unless Dependencies.load_once_paths.include?(dir_path) # I don't understand very well how the load_once_paths works for the moment
        @config.controller_paths.unshift(dir_path) if dir.include?("controllers") and File.exists?(dir_path)
      end

      # load views
      ActionController::Base.prepend_view_path(File.join(@path, 'app', 'views'))
      
      # load i18n feature files
      I18n.load_path += Dir[ File.join(@path, 'config', 'locale', '*.{rb,yml}') ]
      I18n.reload!
    end
    
    def load_libs
      # require the main file of the feature/plugin if any
      main_file = "#{@path}/lib/#{@name}.rb"
      require main_file if File.exists?(main_file)
      
      if database_is_ready?
        # require files in lib/overrides
        Dir["#{@path}/lib/overrides/*.rb"].each{ |file| load file }
        
        # constantize files in app/models
        Dir["#{@path}/app/models/*.rb"].each{ |file| File.basename(file).chomp(File.extname(file)).camelize.constantize }
      end
    end
end
