# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout "default"
  
  # Filters
  before_filter :authenticate, :select_theme
  
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
        User.find(session[:user_id])
      rescue
        return false
      end
    end

    def user_home
      permissions_path
    end

    # Called when an user try to acces to an unauthorized page
    def error_access_page(status = 403)
      render :file => "#{RAILS_ROOT}/public/#{status.to_s}.html", :status => status
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
          when *['new', 'create'] + ($permission[controller_path][:add] || [])
            unless can_add?(current_user)
              error_access_page(422)
            end
          when *['edit', 'update'] + ($permission[controller_path][:edit] || [])
            unless can_edit?(current_user)
              error_access_page(422)
            end
          when *['destroy'] + ($permission[controller_path][:delete] || [])
            unless can_delete?(current_user)
              error_access_page(422)
            end
          end # case
        end # if
      end # if
    end # authenticate
    
    def select_theme
      begin
        #OPTIMIZE this code is called at each page loading! can't we avoid to check in the database everytime ?! can't we avoid to check in the filesystem everytime (to limit read acces in HDD)
        choosen_theme = ConfigurationManager.admin_society_identity_configuration_choosen_theme
        choosen_theme_site_path = "/themes/#{choosen_theme}"
        choosen_theme_real_path = "public#{choosen_theme_site_path}"
        if File.exists?(choosen_theme_real_path) and File.directory?(choosen_theme_real_path)
          @theme_path = choosen_theme_site_path
        else
          #select the default theme
          @theme_path = "/themes/osirails-green/stylesheets"
        end
      end
    end
end # class