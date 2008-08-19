class PasswordPoliciesController < ApplicationController
  
  def index
  end
  
  def update
    if request.put?
      # tmp = ConfigurationManager.admin_password_policy
      # tmp["actual"] = params[:level]
      params[:level].nil? ? flash[:error][0] = "Vous devez séléctionner au moins une valeur" : ConfigurationManager.admin_actual_password_policy = params[:level]
      params[:pattern].nil? ? flash[:error][1] = "Le pattern ne correspond pas au modèle, consultez l'aide pour plus d'informations" : ConfigurationManager.admin_user_pattern = params[:pattern].to_s
      params[:validity].to_i <= 0 ? flash[:error][2] = "Vous devez choisir une période de validitée positive" : ConfigurationManager.admin_password_validity = params[:validity]
      flash[:notice] = "Modifications appliquées avec succés"
      redirect_to :action => "index"
    else
      flash[:notice] = "Tentative de modification frauduleuse"
      redirect_to :action => "index"
    end
  end
  
end
