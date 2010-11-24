## Manage the override of each features
## OPTIMIZE Move this block of code to a better place
#if Rails.env.development?
#  features = Dir.open("#{RAILS_ROOT}/lib/features")
#  features.sort.each do |dir|
#    next if dir.starts_with?('.') or !File.directory?("#{RAILS_ROOT}/lib/features/#{dir}")
#    # next if !Feature.find_by_name(dir).activated?
#    file_path = "#{RAILS_ROOT}/lib/features/#{dir}/overrides.rb"
#    load file_path if File.exist?(file_path)
#  end
#end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Osirails::ContextualMenu
  
  set_journalization_actor
  
  helper :all, :journalization # include all helpers, all the time
  layout "default"
  
  # Filters
  before_filter :configure_model, :authenticate, :select_theme, :initialize_contextual_menu, :select_time_zone, :select_language
  before_filter :load_features_overrides if Rails.env.development?
  
  # Password will not displayed in log files
  filter_parameter_logging "password"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'd8f4c2392e017e10ad303575cb57d1cd', :except => [:login]

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  ActionController::Base.session_options[:session_expires] = 1.day.from_now

  # Global variables
  $permission ||= {}
  
  @@models ||= {}
  
  def context_menu
    class_name_and_object_ids = params.detect{ |h| h.first.end_with?("_ids") }            # ["resource_ids", ["1"]]
    class_name                = class_name_and_object_ids.first.gsub("_ids", "").camelize # "Resource"
    underscored_class_name    = class_name.underscore                                     # "resource"
    object_id                 = class_name_and_object_ids.last.first                      # "1"
    controller_folder_name    = self.class.name.gsub("Controller","").underscore          # "resources"
    @ids                      = class_name_and_object_ids.last                            # ["1"]
    choice                    = @ids.many? ? "multiple" : "single"                        # "single"
    
    controller_template = "#{controller_folder_name}/#{underscored_class_name}_context_menu_#{choice}_selection" # resources/resource_context_menu_single_selection
    model_template      = "shared/#{underscored_class_name}_context_menu_#{choice}_selection"                    # shared/resource_context_menu_single_selection
    default_template    = "shared/context_menu_#{choice}_selection"                                              # shared/context_menu_single_selection
    
    template   = params["#{underscored_class_name}_#{choice}_selection_template".to_sym]
    template ||= controller_template if template_exists?(controller_template)
    template ||= model_template      if template_exists?(model_template)
    template ||= default_template
    
    @object = class_name.constantize.find(object_id)
    
    render :template => template, :layout => false
  end
    
  protected
    def current_menu
      #OPTIMIZE remove the reference to step (which comes from sales feature) and override this method in the feature sales to add the step notion
      step = current_order_step if respond_to?("current_order_step")
      menu = step || controller_name
      Menu.find_by_name(menu) or raise "The controller '#{controller_name}' should have a menu with the same name"
    end
    
    # Method to permit to add permission to an action in a controller
    # options = {:list => ['myaction']}
    def self.method_permission(options)
      $permission[controller_path] ||= options
    end
    
    def self.model(model_name)
      @@models[controller_path] ||= model_name
    end

    # This method return the feature name
    def feature_name(file)
      file_name = file.split("/").slice(0...-3).join('/') + '/config.yml'
      yaml = YAML.load(File.open(file_name))
      yaml['name']
    end

    # This methods return an array with options configuration for a controller
    def search_methods(file)
      ConfigurationManager.find_configurations_for(feature_name(file), controller_path)
    end

    def current_user # same as ApplicationHelper#current_user
      @current_user ||= User.find_by_id(session[:user_id])
    end

    # Called when an user try to acces to an unauthorized page
    def error_access_page(status = nil)
      render_optional_error_file(status)
    end
    
    def configure_model
      @@models[controller_path] ||= controller_name.singularize.camelize
    end
    
    def generate_random_id(length = 8) # same as ApplicationHelper#generate_random_id
      chars = ['A'..'Z', 'a'..'z', '0'..'9'].map{|r|r.to_a}.flatten
      Array.new(length).map{chars[rand(chars.size)]}.join
    end
    
    ######################################################################
    # These methods are used to hack params into sales (CustomerContoller, SubcontractorController etc ...)
    # TODO remove that methods when the hack become useless
     
    # Method used to remove some keys that mustn't be passed to the model
    def clean_params(array, key)
      array.each do |hash|
        hash.delete(key)
      end
      array
    end
    
    # Method to find if the id passed as argument is a fake one used to retrieve new_record's numbers
    def is_a_fake_id?(id)
      /new_record_([0-9])*/.match(id)
    end
    
    # Method to remove fake ids that become useless after params hack
    def remove_fake_ids(params)
      if params.is_a?(Array)
        params.each do |element|
          element[:id] = nil if is_a_fake_id?(element[:id])
        end
      elsif params.is_a?(Hash)
        params[:id] = nil if is_a_fake_id?(params[:id])
      end
    end
    ######################################################################
      
  private

    # Do every verification before shows the page
    def authenticate
      if session[:user_id].nil? or current_user.class != User # if session is empty or if current_user return false
        session[:initial_uri] = request.request_uri
        redirect_to login_path
        flash[:error] = "Vous n'êtes pas connecté !"
      else # if user is logged and current_user return a valid user
        current_user.update_activity
        if session[:user_expired]
          redirect_to :controller => 'account', :action => 'expired_password'
        else
          return error_access_page(403) unless current_menu.can_access?(current_user)
          
          return unless @@models[controller_path] and !@@models[controller_path].blank?
          model = @@models[controller_path].constantize rescue nil
          
          if model and model.respond_to?(:business_object)
            $permission[controller_path] ||= {}
            
            case params[:action]
            # LIST
            when *['index'] + ($permission[controller_path][:list] || [])
              return error_access_page(403) unless model.can_list?(current_user)
            
            # VIEW
            when *['show'] + ($permission[controller_path][:view] || [])
              return error_access_page(403) unless model.can_view?(current_user)
            
            # ADD
            when *['new', 'create'] + ($permission[controller_path][:add] || [])
              return error_access_page(403) unless model.can_add?(current_user)
            
            # EDIT
            when *['edit', 'update'] + ($permission[controller_path][:edit] || [])
              return error_access_page(403) unless model.can_edit?(current_user)
            
            # DELETE
            when *['destroy'] + ($permission[controller_path][:delete] || [])
              return error_access_page(403) unless model.can_delete?(current_user)
            
            # OTHER METHODS
            else
              if model.respond_to?("can_#{params[:action]}?")
                return error_access_page(403) unless model.send("can_#{params[:action]}?", current_user)
              end
            end
          end
        end # if
      end # if
    end # authenticate
    
    def select_theme
      #OPTIMIZE this code is called at each page loading! can't we avoid to check in the database everytime ?! can't we avoid to check in the filesystem everytime (to limit read acces in HDD)
      #return $CURRENT_THEME_PATH unless $CURRENT_THEME_PATH.nil? # this works, but we need to observe a changement in the configuration manager to flush the global variable when the "admin_society_identity_configuration_choosen_theme" variable has changed!
      choosen_theme = ConfigurationManager.admin_society_identity_configuration_choosen_theme
      choosen_theme_site_path = "/themes/#{choosen_theme}"
      choosen_theme_real_path = "public#{choosen_theme_site_path}"
      if File.exists?(choosen_theme_real_path) and File.directory?(choosen_theme_real_path)
        $CURRENT_THEME_PATH = choosen_theme_site_path
      else
        #select the default theme
        $CURRENT_THEME_PATH = "/themes/osirails-green"
      end
    end
    
    def select_time_zone
      #OPTIMIZE this code is called at each page loading! can't we avoid to check in the database everytime ?! can't we avoid to check in the filesystem everytime (to limit read acces in HDD)
      Time.zone = ConfigurationManager.admin_society_identity_configuration_time_zone
    end
    
    def select_language
      #OPTIMIZE this code is called at each page loading! can't we avoid to check in the database everytime ?! can't we avoid to check in the filesystem everytime (to limit read acces in HDD)
      I18n.default_locale = ConfigurationManager.admin_society_identity_configuration_choosen_language
    end
    
    # this method permits to load the 'overrides.rb' file for each feature before each loaded page in the browser.
    # that is necessary only on development environment, because the classes cache is cleaned every time in this environment.
    def load_features_overrides
      FeatureManager.loaded_feature_paths.each do |feature_path|
        Dir["#{feature_path}/lib/overrides/*.rb"].each{ |file| load file }
      end
    end
    
    def initialize_contextual_menu
      @contextual_menu = ContextualMenu.new
    end
end # class
