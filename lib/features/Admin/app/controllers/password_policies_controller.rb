class PasswordPoliciesController < ApplicationController
  
  def index
  end
  
  def update
    # verify the submit method 
    if request.put?
     
     # create without save an employe to test the validity of pattern into admin when submiting 
     e = Employee.new(:last_name => "jean", :first_name => "paul", :society_email => "toto@emr-oi.fr",:email => "toto@emr-oi.fr",:social_security => "1111111111111 11")
     response = e.pattern(params[:pattern],e)
     
     # if there is one error then errors flashes are displayed but value into DB are not modified
      if !params[:level].nil? and params[:pattern]!="" and params[:validity]!="" and params[:validity].size <= 5  and !(/^([0-9])*$/.match(params[:validity]).nil?) and Employee.pattern_error == false
        ConfigurationManager.admin_actual_password_policy = params[:level]
        ConfigurationManager.admin_user_pattern = params[:pattern].to_s
        params[:validity].to_i < 0 ? ConfigurationManager.admin_password_validity = 0 : ConfigurationManager.admin_password_validity = params[:validity].to_i
        flash[:notice] = "Modifications appliquées avec succés"
        redirect_to :action => "index"
      else
        flash[:error] = "Erreur : <ul>"
        flash[:error] += "<li> Vous devez séléctionner au moins une politique de mot de passe </li>" if params[:level].nil?
        flash[:error] += "<li> Le modèle de création d'user est invalide, consultez l'aide pour plus d'informations </li>" if params[:pattern]==""
        flash[:error] += "<li> Vous devez entrer une durée de validité du mot de passe </li>"  if params[:validity]==""
        flash[:error] += "<li>" + response + "</li>" unless Employee.pattern_error == false
        flash[:error] += "<li> Vous devez entrer un chiffre pour la durée de validité </li>" if (/^([0-9])*$/.match(params[:validity]).nil?)
        params[:validity].size > 8 ? validity = params[:validity][0..7] + "..." : validity = params[:validity]
        flash[:error] += "<li> Durée de validité de mot de passe [" + validity + "] invalide</li>" if params[:validity].to_i.to_s.size>5
        flash[:error] += "</ul>"

        flash.now[:error]
      end
        
      
    else
      flash[:error] = "Tentative de modification frauduleuse"
      redirect_to :action => "index"
    end
  end
  
end
