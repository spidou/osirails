class FactorsController < ApplicationController
  
  # GET /factors
  def index
    @factors = Factor.all.paginate(:page => params[:page], :per_page => Factor::FACTORS_PER_PAGE)
  end
  
  # GET /factors/:id
  def show
    @factor = Factor.find(params[:id])
  end
  
  # GET /factors/new
  def new
    @factor = Factor.new
  end

  # POST /factors
  def create
    @factor = Factor.new(params[:factor])
    if @factor.save
      flash[:notice] = "Société d'affacturage ajoutée avec succès"
      redirect_to factor_path(@factor)
    else
      render :action => 'new'
    end
  end

  # GET /factors/:id/edit
  def edit
    @factor = Factor.find(params[:id])
  end

  # PUT /factors/:id
  def update
    @factor = Factor.find(params[:id])
    if @factor.update_attributes(params[:factor])
      flash[:notice] = "La société d'affacturage a été modifiée avec succès"
      redirect_to factor_path(@factor)
    else
      render :action => 'edit'
    end
  end

  # DELETE /factors/:id
  def destroy
    @factor = Factor.find(params[:id])
    if @factor.destroy
      flash[:notice] = "La société d'affacturage a été supprimée avec succès"
      redirect_to(factors_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression de la société d'affacturage"
      redirect_to :back
    end
  end

end
