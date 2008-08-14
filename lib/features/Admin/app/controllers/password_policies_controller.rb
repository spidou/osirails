class PasswordPoliciesController < ApplicationController
  
  def index
  end
  
  def update
    tmp = ConfigurationManager.admin_password_policy
    tmp["actual"] = params[:level]
    ConfigurationManager.admin_password_policy = tmp 
    ConfigurationManager.admin_user_pattern = params[:pattern]
    ConfigurationManager.admin_password_validity = params[:validity]
    flash[:notice] = "Modifications appliquées avec succés"
    render :action => "index"
  end
  
end
