class ServicesController < ApplicationController
  # GET /services
  def index
    @add = self.can_add?(current_user)
    @edit = self.can_edit?(current_user)
    @delete = self.can_delete?(current_user)
  end
  
  # GET /services/new
  def new
    @service = Service.new
    @services = Service.get_structured_services("....")
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    @services = Service.get_structured_services("....", @service.id)
  end

  # POST /services
  def create
    @service = Service.new(params[:service])
    @services = Service.get_structured_services("....", @service.id)
    if @service.save
      flash[:notice] = 'Le service est bien cr&eacute;&eacute;.'
      redirect_to( :action => "index" )
    else
      render :action => "new"
    end
  end
  
  # PUT /services/1
  def update
    @service = Service.find(params[:id])
    @services = Service.get_structured_services("....", @service.id)
    @service.old_service_parent_id, @service.update_service_parent = @service.service_parent_id, true
    if @service.update_attributes(params[:service])
      flash[:notice] = 'Le service est bien mise à jour.'
      redirect_to services_path
    else
      flash[:error] = 'Le service ne peut être d&eacute;plac&eacute;'
      render :action => 'edit'
    end
  end

  # DELETE /services/1
  def destroy
    @service = Service.find(params[:id])
    if @service.can_delete?
      @service.destroy
      flash[:notice] = "Le service est bien supprim&eacute;"
    else
      flash[:error] = "Le service ne peut être supprim&eacute"
    end
    redirect_to services_path
  end
  
end
