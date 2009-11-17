class SocietyIdentityConfigurationController < ApplicationController
  before_filter :load_configuration, :only => [ :show, :edit ]
  
  # GET /society_identity_configuration
  def show
  end
  
  # GET /society_identity_configuration/edit
  def edit
  end
  
  # PUT /society_identity_configuration
  def update
    transaction_success = Configuration.transaction do
      for parameter in search_methods(__FILE__)
        ConfigurationManager.send(parameter+"=", params[parameter]) if params[parameter]
      end
    end
    
    if transaction_success
      flash[:notice] = "Les modifications ont été prises en compte"
      redirect_to :action => :show
    else
      flash[:error] = "Les modifications ont échoué car une erreur inattendue est survenue"
      redirect_to :action => :edit
    end
  end
  
  private
    def load_configuration
      @parameters = {}
      @descriptions = {}
      for parameter in search_methods(__FILE__) do
        @parameters[parameter] = ConfigurationManager.send(parameter)
        @descriptions[parameter] = ConfigurationManager.send("#{parameter}_desc") + " :"
      end
    end
end
