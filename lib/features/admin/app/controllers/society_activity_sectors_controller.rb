class SocietyActivitySectorsController < ApplicationController

  # GET /society_activity_sectors
  def index
    @society_activity_sectors = SocietyActivitySector.activates.paginate(:page => params[:page], :per_page => SocietyActivitySector::SOCIETY_ACTIVITY_SECTORS_PER_PAGE)
  end
  
  # GET /society_activity_sectors/new
  def new
    @society_activity_sector = SocietyActivitySector.new
  end
  
  # GET /society_activity_sectors/1/edit
  def edit
    @society_activity_sector = SocietyActivitySector.find(params[:id])
  end
  
  # POST /society_activity_sectors
  def create
    @society_activity_sector = SocietyActivitySector.new(params[:society_activity_sector])
    if @society_activity_sector.save
      flash[:notice] = "Le secteur d'activité a été créé avec succès"
      redirect_to :action => 'index'
    else
      render :action => "new"
    end
  end
  
  # PUT /society_activity_sectors/1
  def update
    @society_activity_sector = SocietyActivitySector.find(params[:id])
    if @society_activity_sector.update_attributes(params[:society_activity_sector])
      flash[:notice] = "Le secteur d'activité est bien mise à jour"
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end
  
  # DELETE /society_activity_sectors/1
  def destroy
    @society_activity_sector = SocietyActivitySector.find(params[:id])
    @society_activity_sector.activated = false
    if @society_activity_sector.save
      flash[:notice] = "Le secteur d'activité a bien été supprimé"
    else
      flash[:error] = "Une erreur est survenue à la suppression du secteur d'activités"
    end
    
    redirect_to(society_activity_sectors_url)
  end
  
end
