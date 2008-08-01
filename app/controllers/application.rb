# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :authenticate
  include Permissible::ClassMethode

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

  ConfigurationManager.initialize

  protected

  # Method to permit to add permission to an action in a controller
  # options = {:list => ['myaction']}
  def self.method_permission(options)
    $permission[controller_path] = options
  end

  private

  # Called when an user try to acces to an unauthorized page
  def unauthorized_action
    render :text => "Vous n'avez pas le droit d'effectuer cette action"
  end

  # Do every verification before shows the page
  def authenticate
    if session[:user_id].nil? # If you're not logged
      session[:initial_uri] = request.request_uri
      redirect_to login_path
      flash[:error] = "Vous n'êtes pas logger !"
    else # If you're logged
      current_user = User.find(session[:user_id])
      current_user.update_activity
      $permission[controller_path] ||= {}
      case params[:action]
      when *['index'] + ($permission[controller_path][:list] || [])
        unless can_list?(:user => current_user, :controller_name => controller_path)
          unauthorized_action
        end
      when *['show'] + ($permission[controller_path][:view] || [])
        unless can_view?(:user => current_user, :controller_name => controller_path)
          unauthorized_action
        end
      when *['add', 'create'] + ($permission[controller_path][:add] || [])
        unless can_add?(:user => current_user, :controller_name => controller_path)
          unauthorized_action
        end
      when *['edit', 'update'] + ($permission[controller_path][:edit] || [])
        unless can_edit?(:user => current_user, :controller_name => controller_path)
          unauthorized_action
        end
      when *['delete', 'destroy'] + ($permission[controller_path][:delete] || [])
        unless can_delete?(:user => current_user, :controller_name => params[:controller])
          unauthorized_action
        end
      end # case
    end # if
  end # authenticate
end # class
