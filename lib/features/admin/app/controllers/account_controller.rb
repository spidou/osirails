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
        
    if @user = User.find(:first, :conditions => ['username LIKE BINARY ?', params[:username]], :include => :employee)
      if @user.compare_password(params[:password])
        if @user.enabled?
          @user.update_connection
          session[:user_id] = @user.id
          session[:initial_uri] ||= user_home
          session[:user_expired] = @user.expired?
          redirect_to session[:initial_uri]
          flash[:notice] = "Connexion réussie"
        else
          flash[:error] = "Votre compte est désactivé"
        end
        session[:tentative] = 0
        return
      end
    end
    redirect_to login_path
    flash[:error] = "Le nom d'utilisateur et le mot de passe ne correspondent pas. Veuillez réessayer."
    
    # Anti-flood system
    session[:tentative] ||= 0
    if session[:tentative] >= TENTATIVE_LOGIN - 1
      flash[:error] = "Trois tentatives de connexion detectées, veuillez patienter quelques instants avant de réessayer ..."
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
    if (Time.now - current_user.last_activity) > 5.minutes
      redirect_to :action => 'logout'
      flash[:error] = 'Votre session a expir&eacute;e'
      return
    end
    flash.now[:error] = "Votre mot de passe est expiré. Merci d'en choisir un autre."
    return unless request.post?
    user = current_user
    if user.update_attributes(params[:user])
      redirect_to session[:initial_uri]
      flash[:notice] = "Votre mot de passe a été mis à jour avec succés"
    end
    if user.save
      session[:user_expired] = false
    else
      different_password = "Vous devez choisir un nouveau mot de passe, différent de votre ancien mot de passe."
      match_confirmation = "Vous devez entrer deux fois votre mot de passe pour le valider."
      message = (params[:user][:password] == params[:user][:password_confirmation])? different_password : match_confirmation
      flash[:error] = message
    end
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
