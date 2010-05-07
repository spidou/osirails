class SubcontractorsController < ApplicationController
  helper :thirds, :contacts, :documents, :numbers
  
  # GET /subcontractors
  def index
    @subcontractors = Subcontractor.activates.paginate(:page => params[:page], :per_page => Subcontractor::SUBCONTRACTORS_PER_PAGE)
  end
  
  # GET /subcontractors/:id
  def show
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  # GET /subcontractors/new
  def new
    @subcontractor = Subcontractor.new
  end

  # POST /subcontractors
  def create
    @return_uri = params[:return_uri] # permit to be redirected to order creation (or other uri) when necessary
    
    @subcontractor = Subcontractor.new(params[:subcontractor])
    if @subcontractor.save
      flash[:notice] = "Sous-traitant ajouté avec succès"
      redirect_to subcontractor_path(@subcontractor)
    else
      render :action => 'new'
    end
  end

  # GET /subcontractors/:id/edit
  def edit
    @subcontractor = Subcontractor.find(params[:id])
  end

  # PUT /subcontractors/:id
  def update
    @subcontractor = Subcontractor.find(params[:id])
    if @subcontractor.update_attributes(params[:subcontractor])
      flash[:notice] = "Le sous-traitant a été modifié avec succès"
      redirect_to subcontractor_path(@subcontractor)
    else
      render :action => 'edit'
    end
  end

  # DELETE /subcontractors/:id
  def destroy
    @subcontractor = Subcontractor.find(params[:id])
    @subcontractor.activated = false
    if @subcontractor.save
      redirect_to(subcontractors_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du sous-traitant"
      redirect_to :back 
    end
  end
  
end
