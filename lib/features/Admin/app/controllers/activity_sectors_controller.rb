class ActivitySectorsController < ApplicationController

  # GET /activity_sectors
  def index
    @activity_sectors = ActivitySector.activates
  end
  
  # GET /activity_sectors/new
  def new
    @activity_sector = ActivitySector.new
  end
  
  # GET /activity_sectors/1/edit
  def edit
    @activity_sector = ActivitySector.find(params[:id])
  end
  
  # POST /activity_sectors
  def create
    @activity_sector = ActivitySector.new(params[:activity_sector])
    if @activity_sector.save
      flash[:notice] = "Le secteur d'activit&eacute; a &eacute;t&eacute; cr&eacute;&eacute; avec succ&egrave;s"
      redirect_to :action => 'index'
    else
      render :action => "new"
    end
  end
  
  # PUT /activity_sectors/1
  def update
    @activity_sector = ActivitySector.find(params[:id])
    if @activity_sector.update_attributes(params[:activity_sector])
      flash[:notice] = "Le secteur d'activit&eacute; est bien mise &agrave; jour"
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end
  
  # DELETE /activity_sectors/1
  def destroy
    @activity_sector = ActivitySector.find(params[:id])
    @activity_sector.activated = false
    if @activity_sector.save
      flash[:notice] = "Le secteur d'activit&eacute; a bien &eacute;t&eacute; supprim&eacute;"
    else
      flash[:error] = "Une erreur est survenue &agrave; la suppression du secteur d'activit&eacute;s"
    end
    
    redirect_to(activity_sectors_url)
  end
  
end