class ServicesController < ApplicationController
  
  # GET /services
  def index
    @services = Service.mains
  end
  
  # GET /services/new
  def new
    @service = Service.new(:service_parent_id => params[:service_id])
    @services = Service.get_structured_services
    @options = @services.empty? ? {:prompt => "-- Racine --"} : {}
  end
  
  # GET /services/show
  def show
    @service = Service.find(params[:id])
    @schedules = @service.schedule_find.schedules
    @schedules_service = @service.schedule_find.name
    @responsables = []
    @days = {:day => "", :morning_start => "" , :morning_end => "" , :afternoon_start => "", :afternoon_start => ""}
    @members = @service.members
    @responsables = @service.responsibles
  end

  # GET /servicess.employees_services.each do |f|
  def edit
    @service = Service.find(params[:id])
    @services = Service.get_structured_services(@service.id)
    @service.schedule_find.schedules == [] ? @schedules = @service.schedules : @schedules = @service.schedule_find.schedules
    @options =  {:prompt => "-- Racine --"}
  end

  # POST /services
  def create
    @service = Service.new(params[:service])
    @services = Service.get_structured_services(@service.id)
    @schedules = @service.schedules

    params[:schedules].sort.each do |day|  #sort on a hash give an array of arrays containing a couple of [key,value]
      @schedules << Schedule.new(@service.get_time(day[0].to_i,day[1]))
      params[:schedules][day[0]] = @service.get_time(day[0].to_i,day[1])
    end

    if @service.save
      flash[:notice] = 'Le service est bien cr&eacute;&eacute;.'
      redirect_to( :action => "index" )
    else
      render :action => "new"
    end
  end
  
  # PUT /services/1
  def update
    @service = Service.find(params[:id])
    @services = Service.get_structured_services(@service.id)
    @service.old_service_parent_id, @service.update_service_parent = @service.service_parent_id, true
    @schedules = @service.schedules
          
    if @schedules==[]
      params[:schedules].sort.each do |f|
        @schedules << Schedule.new(@service.get_time(f[0].to_i,f[1]))
        params[:schedules][f[0]] = @service.get_time(f[0].to_i,f[1])
      end
    else

      @schedules.each_with_index do |f,i|
        i+=1
        f.update_attributes(@service.get_time(i,params[:schedules][i.to_s]))
        params[:schedules][i.to_s] = @service.get_time(i,params[:schedules][i.to_s])
      end
    end  
      
    
    if @service.update_attributes(params[:service])
      flash[:notice] = 'Le service est bien mise à jour.'
      redirect_to services_path
    else
      flash[:error] = 'Le service ne peut être d&eacute;plac&eacute;'
      render :action => 'edit'
    end
  end

  # DELETE /services/1
  def destroy
    @service = Service.find(params[:id])
    if @service.can_be_destroyed?
      @service.destroy
      flash[:notice] = "Le service est bien supprim&eacute;"
    else
      flash[:error] = "Le service ne peut être supprim&eacute"
    end
    redirect_to services_path
  end
  
end
