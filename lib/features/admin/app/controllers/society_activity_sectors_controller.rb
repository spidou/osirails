class SocietyActivitySectorsController < ApplicationController

  # GET /society_activity_sectors
  def index
    @society_activity_sectors = SocietyActivitySector.activates
    # Permissions
    @add = self.can_add?(current_user)
    @edit = self.can_edit?(current_user)
    @delete = self.can_delete?(current_user)
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
      flash[:notice] = "Le secteur d'activit&eacute; a &eacute;t&eacute; cr&eacute;&eacute; avec succ&egrave;s"
      redirect_to :action => 'index'
    else
      render :action => "new"
    end
  end
  
  # PUT /society_activity_sectors/1
  def update
    @society_activity_sector = SocietyActivitySector.find(params[:id])
    if @society_activity_sector.update_attributes(params[:society_activity_sector])
      flash[:notice] = "Le secteur d'activit&eacute; est bien mise &agrave; jour"
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
      flash[:notice] = "Le secteur d'activit&eacute; a bien &eacute;t&eacute; supprim&eacute;"
    else
      flash[:error] = "Une erreur est survenue &agrave; la suppression du secteur d'activit&eacute;s"
    end
    
    redirect_to(society_activity_sectors_url)
  end
  
end