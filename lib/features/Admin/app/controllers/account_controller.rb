class AccountController < ApplicationController
  skip_before_filter :authenticate
  before_filter :logged, :only => [:index, :login, :lost_password]
  before_filter :not_logged, :only => [:logout, :expired_password]
  layout "login"

  # All the following action are accessible without login
  
  def index
    render :action => "login"
  end

  def login
    return unless request.post?
    
    # Anti-flood system
    session[:tentative] ||= 0
    if session[:tentative] >= 3
      flash[:error] = "Trois tentatives de connexion detect&eacute;es, vueillez patienter quelques instants avant de r&eacute;essayer ..."
      if (session[:tentative_time] + 10.seconds) < Time.now
        session[:tentative] = 0 
      end
      return
    end
    
    if @user = User.find_by_username(params[:username], :include => :employee)
      if @user.compare_password(params[:password])
        if @user.enabled == true
          @user.update_connection
          session[:user] = @user
          session[:initial_uri] ||= user_home
          redirect_to session[:initial_uri]
          flash[:notice] = "Connexion r&eacute;ussie"
        else
          flash[:error] = "Votre compte est d&eacute;sactiv&eacute;"
        end
        session[:tentative] = 0
        return
      end
    end
    redirect_to login_path
    flash[:error] = "Le nom d'utilisateur et le mot de passe ne correspondent pas. Veuillez r&eacute;essayer."
    
    # Manage error tentative for the anti-flood
    if session[:tentative] < 3
      session[:tentative] += 1
      session[:tentative_time] = Time.now
    end
  end

  def lost_password
    if !params[:username].nil?
      if User.find_by_username(params[:username])
        AdminMailer.deliver_notice_admin_lost_password(params[:username])
        AdminMailer.deliver_notice_user_lost_password(params[:username])
        flash[:notice] = "L'administrateur a &eacute;t&eacute; pr&eacute;venu que vous voulez modifier votre mot de passe. Merci de patienter."
        redirect_to login_path
      end
    end
  end
  
  # All the following actions are not accessible without login
  
  def logout
    reset_session
    redirect_to login_path
    flash[:notice] = "Vous &ecirc;tes maintenant d&eacute;connect&eacute;"
  end
  
  def expired_password
    flash.now[:error] = "Votre mot de passe est expir&eacute;. Merci d'en choisir un autre."
    return unless request.post?
    current_user.updating_password = true
    if current_user.update_attributes(params[:user])
      current_user.update_attributes(:password_updated_at => Time.now)
      redirect_to session[:initial_uri]
      flash[:notice] = "Votre mot de passe a &eacute;t&eacute; mis &agrave; jour avec succ&egrave;s"
    end
    current_user.updating_password = false
  end
  
  private
    def logged
      if current_user
        redirect_to user_home
      end
    end

    def not_logged
      unless current_user
        redirect_to login_path
      end
    end
end