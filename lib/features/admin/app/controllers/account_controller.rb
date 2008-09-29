class AccountController < ApplicationController
  skip_before_filter :authenticate
  before_filter :logged, :only => [:index, :login, :lost_password]
  before_filter :not_logged, :only => [:logout, :expired_password]
  layout "login"

  # Constants
  TENTATIVE_LOGIN = 3
  
  # All the following action are accessible without login
  
  def index
    render :action => "login"
  end

  def login
    return unless request.post?
        
    if @user = User.find_by_username(params[:username], :include => :employee)
      if @user.compare_password(params[:password])
        if @user.enabled == true
          @user.update_connection
          session[:user] = @user.id
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
    
    # Anti-flood system
    session[:tentative] ||= 0
    if session[:tentative] >= TENTATIVE_LOGIN - 1
      flash[:error] = "Trois tentatives de connexion detect&eacute;es, veuillez patienter quelques instants avant de r&eacute;essayer ..."
      if (session[:tentative_time] + 10.seconds) < Time.now
        session[:tentative] = 0 
      end
      return
    end
    
    # Manage error tentative for the anti-flood
    if session[:tentative] < TENTATIVE_LOGIN
      session[:tentative] += 1
      session[:tentative_time] = Time.now
    end
  end

  def lost_password
    #TODO faire un anti-flood également pour le lost_password!
    if request.post?
      if !params[:username].empty? and (user = User.find_by_username(params[:username])) and user.username != "admin"
        AdminMailer.deliver_notice_admin_lost_password(params[:username])
        AdminMailer.deliver_notice_user_lost_password(params[:username])
        flash[:notice] = "L'administrateur a &eacute;t&eacute; pr&eacute;venu que vous voulez modifier votre mot de passe. Merci de patienter."
        redirect_to login_path
      else
        flash.now[:error] = "Nom d'utilisateur inconnu."
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
    redirect_to :action => 'logout' if (Time.now - current_user.last_activity) > 5.minutes
    flash.now[:error] = "Votre mot de passe est expir&eacute;. Merci d'en choisir un autre."
    return unless request.post?
    user = current_user
    user.updating_password = true
    if user.update_attributes(params[:user])
      user.update_attributes(:password_updated_at => Time.now)
      redirect_to session[:initial_uri]
      flash[:notice] = "Votre mot de passe a &eacute;t&eacute; mis &agrave; jour avec succ&egrave;s"
    end
    user.updating_password = false
    user.save
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