class SocietyIdentityConfigurationController < ApplicationController
  
  # GET /society_identity_configuration
  def show
    @parameters = {}
    for parameter in search_methods(__FILE__) do
      @parameters[parameter] = ConfigurationManager.send(parameter)
    end
  end
  
  # GET /society_identity_configuration/edit
  def edit
    @parameters = {}
    for parameter in search_methods(__FILE__) do
      @parameters[parameter] = ConfigurationManager.send(parameter)
    end
  end
  
  # PUT /society_identity_configuration
  def update
    error = false
    for parameter in search_methods(__FILE__)
      error = true unless ConfigurationManager.send(parameter+"=", params[parameter])
    end
    
    unless error
      flash[:notice] = 'Les modifications ont été prises en compte'
      redirect_to :action => :show
    else
      flash[:error] = 'Les modifications ont échouées'
      redirect_to :action => :edit
    end
  end
  
end
