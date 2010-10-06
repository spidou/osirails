class ConveyancesController < ApplicationController
  
  # GET /conveyances
  def index
    @conveyances = Conveyance.all.paginate(:page => params[:page], :per_page => Conveyance::CONVEYANCES_PER_PAGE)
  end
  
   # GET /conveyances/new
  # GET /conveyances/new?supplier_id=:supplier_id
  def new
    @conveyance = Conveyance.new
  end
  
  # GET /conveyances/:conveyance_id/edit
  def edit
    @conveyance = Conveyance.find(params[:id])
  end
  
  # PUT /conveyances/
  def create
    @conveyance = Conveyance.new(params[:conveyance])
    @conveyance.creator_id = current_user.id
    if @conveyance.save
      flash[:notice] = "Le moyen de transport a été créé avec succès."
      redirect_to conveyances_path
    else
      render :action => "new"
    end
  end
  
  # PUT /coveyances/:coveyance_id/
  def update
    if @conveyance = Conveyance.find(params[:id])
      if @conveyance.update_attributes(params[:conveyance])
        flash[:notice] = "Le moyen de transport a été modifié avec succès"
        redirect_to conveyances_path
      else
        render :action => "edit"
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /conveyances/:conveyance_id
  def destroy
    if (@conveyance = Conveyance.find(params[:id])).can_be_destroyed?
      unless @conveyance.destroy
        flash[:error] = 'Une erreur est survenue lors de la suppression du moyen de transport'
      end
      flash[:notice] = 'La suppression du moyen de transport a été effectué avec succès'
      redirect_to conveyances_path
    else
      error_access_page(412)
    end
  end
  
  def activate
    if (@conveyance = Conveyance.find(params[:id]) and Conveyance.can_activate?)
      unless (@conveyance.activated = true) and @conveyance.save
        flash[:error] = 'Une erreur est survenue lors de l\'activation du moyen de transport'
      end
      flash[:notice] = 'L\'activation du moyen de transport a été effectué avec succès'
      redirect_to conveyances_path
    else
      error_access_page(412)
    end
  end
  
  def deactivate
    if (@conveyance = Conveyance.find(params[:id]) and Conveyance.can_deactivate?)
      unless (@conveyance.activated = false) and @conveyance.save
        flash[:error] = 'Une erreur est survenue lors de l\'activation du moyen de transport'
      end
      flash[:notice] = 'L\'activation du moyen de transport a été effectué avec succès'
      redirect_to conveyances_path
    else
      error_access_page(412)
    end
  end
end
