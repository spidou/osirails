class ActivitySectorsController < ApplicationController

  def index
    @activity_sector = ActivitySector.find(:all, :order => "name", :conditions => {:activated => true})
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /activity_sectors/new
  def new
    @activity_sector = ActivitySector.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # GET /activity_sectors/1/edit
  def edit
    @activity_sector = ActivitySector.find(params[:id])
  end
  
  # POST /activity_sectors
  def create
    @activity_sector = ActivitySector.new(params[:activity_sector])
    respond_to do |format|
      if @activity_sector.save
        flash[:notice] = "Le secteur d'activit&eacute; a &eacute;t&eacute; cr&eacute;&eacute; avec succ&egrave;s"
        format.html { redirect_to( :action => 'index' ) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /activity_sectors/1
  def update
    @activity_sector = ActivitySector.find(params[:id])
    respond_to do |format|
      if @activity_sector.update_attributes(params[:activity_sector])
        flash[:notice] = "Le secteur d'activit&eacute; est bien mise à jour"
        format.html { redirect_to( :action => 'index' ) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /activity_sectors/1
  def destroy
    @activity_sector = ActivitySector.find(params[:id])
    @activity_sector.activated= false
    @activity_sector.save
    respond_to do |format|
      flash[:notice] = "Le secteur d'activit&eacute; est bien supprim&eacute;"
      format.html { redirect_to(activity_sectors_url) }
    end
  end
  
end