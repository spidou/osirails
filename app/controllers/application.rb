# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout "default"
  #layout "default_original"
  
  # Filters
  before_filter :authenticate
  
  # Includes
  include Permissible::InstanceMethods
  
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
  
  protected
    # Method to permit to add permission to an action in a controller
    # options = {:list => ['myaction']}
    def self.method_permission(options)
      $permission[controller_path] = options
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
        User.find(session[:user])
      rescue
        return false
      end
    end

    def user_home
      permissions_path
    end

    # Called when an user try to acces to an unauthorized page
    def error_access_page(status = nil)
      case status
      when 422
        render :file => "#{RAILS_ROOT}/public/422.html", :status => "422"
      when 403
        render :file => "#{RAILS_ROOT}/public/403.html", :status => "403"
      else
        render :text => "Vous n'avez pas le droit d'effectuer cette action", :status => 401
      end
    end

  private

    # Do every verification before shows the page
    def authenticate
      if session[:user].nil? # If you're not logged
        session[:initial_uri] = request.request_uri
        redirect_to login_path
        flash[:error] = "Vous n'êtes pas logger !"
      else # If you're logged
        current_user.update_activity
        if current_user.expired?
          redirect_to :controller => 'account', :action => 'expired_password'
        else
          # Manage permissions for actions
          $permission[controller_path] ||= {}
          case params[:action]
          when *['index'] + ($permission[controller_path][:list] || [])
            unless can_list?(current_user)
              error_access_page
            end
          when *['show'] + ($permission[controller_path][:view] || [])
            unless can_view?(current_user)
              error_access_page
            end
          when *['add', 'create'] + ($permission[controller_path][:add] || [])
            unless can_add?(current_user)
              error_access_page(422)
            end
          when *['edit', 'update'] + ($permission[controller_path][:edit] || [])
            unless can_edit?(current_user)
              error_access_page(422)
            end
          when *['delete', 'destroy'] + ($permission[controller_path][:delete] || [])
            unless can_delete?(current_user)
              error_access_page(422)
            end
          end # case
        end # if
      end # if
    end # authenticate
end # class
