class ServicesController < ApplicationController
  # GET /services
  def index
    @services = Service.find( :all, :order => 'service_parent_id' )
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /services/new
  def new
    @service = Service.new
    @services = Service.find(:all)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    @services = Service.find(:all)
  end

  # POST /services
  def create
    @service = Service.new(params[:service])
    respond_to do |format|
      if @service.save
        flash[:notice] = 'Le service est bien cr&eacute;&eacute;.'
        format.html { redirect_to( :action => "index" ) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /services/1
  def update
    @service = Service.find(params[:id])
    @service.old_service_parent_id, @service.update_service_parent = @service.service_parent_id, true
    if @service.update_attributes(params[:service])
      flash[:notice] = 'Le service est bien mise à jour.'
      redirect_to services_path
    else
      redirect_to :action => 'edit'
      flash[:error] = 'Le service ne peut être d&eacute;plac&eacute;'
    end
  end

  # DELETE /services/1
  def destroy
    @service = Service.find(params[:id])
    @service.destroy
    respond_to do |format|
      flash[:notice] = "Le service est bien supprim&eacute;"
      format.html { redirect_to(services_url) }
    end
  end
  
end