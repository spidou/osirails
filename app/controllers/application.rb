## Manage the override of each features
## OPTIMIZE Move this block of code to a better place
#if RAILS_ENV == 'development'
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
  helper :all # include all helpers, all the time
  layout "default"
  
  # Filters
  before_filter :configure_model, :authenticate, :select_theme
  before_filter :load_features_overrides if RAILS_ENV == "development"
  
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
  
  def current_menu
    #OPTIMIZE remove the reference to step (which comes from sales feature) and override this method in the feature sales to add the step notion
    step = current_order_step if respond_to?("current_order_step")
    menu = step || controller_name
    Menu.find_by_name(menu) or raise "The controller '#{controller_name}' should have a menu with the same name"
  end
  
  protected
    # Method to permit to add permission to an action in a controller
    # options = {:list => ['myaction']}
    def self.method_permission(options)
      $permission[controller_path] = options
    end
    
    def self.model(model_name)
      @@models[controller_path] = model_name
    end

    # This method return the feature name
    def feature_name(file)
      file = file.split("/").slice(0...-3).join('/')
      yaml = YAML.load(File.open(file+'/config.yml'))
      yaml['name']
    end

    # This methods return an array with options configuration for a controller
    def search_methods(file)
      ConfigurationManager.find_configurations_for(feature_name(file), controller_path)
    end

    def current_user
      begin
        User.find(session[:user_id])
      rescue
        return false
      end
    end

    def user_home
      permissions_path
    end

    # Called when an user try to acces to an unauthorized page
    def error_access_page(status = nil)
      render_optional_error_file(status)
    end
    
    # this method need to hack htmldoc (/var/lib/gems/1.8/gems/htmldoc-0.2.1/lib/htmldoc.rb > under ubuntu 8.04)
    # add 'line.strip!' just after the line 185
    def render_pdf
      require 'htmldoc'
      data = render_to_string(:action => "#{params[:action]}.pdf.erb", :layout => false)
      pdf = PDF::HTMLDoc.new
      pdf.set_option :bodycolor, :white
      pdf.set_option :toc, false
      pdf.set_option :charset, 'utf-8'
      pdf.set_option :portrait, true
      pdf.set_option :links, false
      pdf.set_option :webpage, true
      pdf.set_option :left, '1cm'
      pdf.set_option :right, '1cm'
      pdf << data
      pdf.generate
    end
    
    def configure_model
      @@models[controller_path] ||= controller_name.singularize.camelize
    end

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
            code = request.get? ? 403 : 422
            
            case params[:action]
            # LIST
            when *['index'] + ($permission[controller_path][:list] || [])
              return error_access_page(code) unless model.can_list?(current_user)
            
            # VIEW
            when *['show'] + ($permission[controller_path][:view] || [])
              return error_access_page(code) unless model.can_view?(current_user)
            
            # ADD
            when *['new', 'create'] + ($permission[controller_path][:add] || [])
              return error_access_page(code) unless model.can_add?(current_user)
            
            # EDIT
            when *['edit', 'update'] + ($permission[controller_path][:edit] || [])
              return error_access_page(code) unless model.can_edit?(current_user)
            
            # DELETE
            when *['destroy'] + ($permission[controller_path][:delete] || [])
              return error_access_page(code) unless model.can_delete?(current_user)
            
            # OTHER METHODS
            else
              if model.respond_to?("can_#{params[:action]}?")
                return error_access_page(code) unless model.send("can_#{params[:action]}?", current_user)
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
    
    # this method permits to load the 'overrides.rb' file for each feature before each loaded page in the browser.
    # that is necessary only on development environment, because the classes cache is cleaned every time in this environment.
    def load_features_overrides
      unless !defined?($activated_features_path)
        ($activated_features_path).each do |feature_path|
          override_path = File.join(feature_path, "overrides.rb")
          load override_path if File.exists?(override_path)
        end
      else
        raise "global variable $activated_features_path is not instanciated"
      end
    end
end # class
