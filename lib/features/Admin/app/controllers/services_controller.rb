class ServicesController < ApplicationController
  # GET /services
  def index
    @services = Service.find( :all, :order => 'name' )
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /services/new
  def new
    @service = Service.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
  end

  # POST /services
  def create
    @service = Service.new(params[:service])
    respond_to do |format|
      if @service.save
        flash[:notice] = 'Le service est bien cr&eacute;e.'
        format.html { redirect_to( :action => "index" ) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = Service.find(params[:id])
    respond_to do |format|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Le service est bien mise à jour.'
        format.html { redirect_to( :action => "index" ) }
      else
        format.html { render :action => "edit" }
      end
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