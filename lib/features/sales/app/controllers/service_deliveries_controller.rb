class ServiceDeliveriesController < ApplicationController
  
  before_filter :find_service_delivery, :except => [ :index, :new, :create ]
  
  # GET /service_deliveries
  def index
    build_query_for("service_delivery_index")
  end
  
  # GET /service_deliveries/:id
  def show
  end
  
  # GET /service_deliveries/new
  def new
    @service_delivery = ServiceDelivery.new
  end

  # POST /service_deliveries
  def create
    @service_delivery = ServiceDelivery.new(params[:service_delivery])
    if @service_delivery.save
      flash[:notice] = "Prestation ajoutée avec succès"
      redirect_to(service_delivery_path(@service_delivery))
    else
      render :action => 'new'
    end
  end

  # GET /service_deliveries/:id/edit
  def edit
  end

  # PUT /service_deliveries/:id
  def update
    if @service_delivery.update_attributes(params[:service_delivery])
      flash[:notice] = "La prestation a été modifiée avec succès"
      redirect_to service_delivery_path(@service_delivery)
    else
      render :action => 'edit'
    end
  end

  # DELETE /service_deliveries/:id
  def destroy
    if @service_delivery.save
      flash[:notice] = "La prestation a été supprimée avec succès"
      redirect_to(service_deliveries_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression de la prestation"
      redirect_to :back
    end
  end
  
  private
    def find_service_delivery
      id = params[:id] || params[:service_delivery_id]
      @service_delivery = ServiceDelivery.find(id) if id
    end
  
end
