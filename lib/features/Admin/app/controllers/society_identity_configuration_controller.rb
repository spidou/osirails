class SocietyIdentityConfigurationController < ApplicationController
  
  # GET /society_identity_configuration
  def index
    @parameters = search_methods(__FILE__)
  end
  
  # GET /society_identity_configuration/edit
  def edit
    @parameters = search_methods(__FILE__)
  end
  
  # POST /society_identity_configuration
  def update
    @parameters = search_methods(__FILE__)
    for parameter in @parameters
      ConfigurationManager.send(parameter+"=", params[parameter])
    end
    flash[:notice] = "Configurations prises en comptes"
    redirect_to :action => 'index'
  end
  
end
