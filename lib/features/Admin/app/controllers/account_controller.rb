class AccountController < ApplicationController
  skip_before_filter :authenticate

  def index
  end

  def login
    if @user = User.find_by_username(params[:username])
      if @user.compare_password(params[:password])
        if @user.enabled == true
          @user.update_connection
          session[:user_id] = @user.id
          session[:initial_uri] ||= permissions_path
          redirect_to session[:initial_uri]
          flash[:notice] = "Authentification réussie"
        else
          flash[:error] = "Votre compte est désactivé"
        end
        return
      end
    end
    redirect_to login_path
    flash[:error] = "Erreur: username ou mot de passe incorrecte"
  end

  def logout
    reset_session
    redirect_to login_path
    flash[:notice] = "Vous êtes maintenant déconnecté"
  end

  def lost_password
    if !params[:username].nil?
      if User.find_by_username(params[:username])
        AdminMailer.deliver_notice_admin_lost_password(params[:username])
        AdminMailer.deliver_notice_user_lost_password(params[:username])
        flash[:notice] = "L'administrateur a été prévenu"
        redirect_to login_path
      end
    end
  end
end
