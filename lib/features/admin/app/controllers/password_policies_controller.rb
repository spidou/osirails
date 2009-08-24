class PasswordPoliciesController < ApplicationController
  before_filter :load_configuration, :only => [ :show, :edit ]
  
  # GET /password_policies
  def show
  end
  
  # GET /password_policies/edit
  def edit
  end
  
  # PUT /password_policies
  def update
    errors = []
    unless params[:level]
      errors << "Vous devez choisir votre politique de mot de passe."
    end
   
    if params[:pattern].blank?
      errors << "Le modèle de création automatique des comptes utilisateurs est invalide. Consultez l'aide pour plus d'informations."
    end
   
    if params[:validity].blank? or params[:validity].to_i < 0 or /^([0-9])*$/.match(params[:validity]).nil?
      errors << "Vous devez entrer un chiffre (positif) pour le délai d'expiration des mots de passe"
    end
   
    if errors.empty?
      transaction_success = Configuration.transaction do
        ConfigurationManager.admin_actual_password_policy = params[:level]
        ConfigurationManager.admin_user_pattern           = params[:pattern].to_s
        ConfigurationManager.admin_password_validity      = params[:validity].to_i
      end
      
      if transaction_success
        flash[:notice] = "Les modifications ont été appliquées avec succès"
        redirect_to :action => :show
      else
        flash[:error] = "Les modifications ont échoué car une erreur inattendue est survenue"
        redirect_to :action => :edit
      end
    else
      flash[:error] = errors.join('<br/>')
      redirect_to :action => :edit
    end
  end
  
  private
    def load_configuration
      #@level    = params[:level].nil? ? ConfigurationManager.admin_actual_password_policy : params[:level]
      #@validity = params[:validity].nil? ? ConfigurationManager.admin_password_validity : params[:validity]
      #@pattern  = params[:pattern].nil? ? ConfigurationManager.admin_user_pattern : params[:pattern]
      
      @level    = ConfigurationManager.admin_actual_password_policy
      @validity = ConfigurationManager.admin_password_validity
      @pattern  = ConfigurationManager.admin_user_pattern
    end
end
