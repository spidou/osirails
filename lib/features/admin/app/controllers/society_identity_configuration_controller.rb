class SocietyIdentityConfigurationController < ApplicationController
  
  # GET /society_identity_configuration
  def show
    @parameters = {}
    for parameter in search_methods(__FILE__) do
      @parameters[parameter] = ConfigurationManager.send(parameter)
    end
    # Permissions
    @edit = self.can_edit?(current_user)
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
    for parameter in search_methods(__FILE__)
      ConfigurationManager.send(parameter+"=", params[parameter])
    end
    flash[:notice] = "Les modifications ont &eacute;t&eacute; prises en compte"
    redirect_to :action => :show
  end
  
end
