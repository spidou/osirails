class CheckingsController < ApplicationController

  # GET /checkings
  def index
    if !current_user.employee.nil?
      @employees       = current_user.employee.subordinates
      @view_cancelled  = params[:cancelled] || false                                                    # if true permit to see cancelled checkings     
      @employee_id     = params[:employee_id].to_i || (@employees.first ? @employees.first.id : nil)
      @date            = (params[:date] || Date.today.monday).to_date
      @chekings        = []
      
      unless @employee_id.nil?
        options = {:conditions => ["employee_id =? and date >=? and date <=?", @employee_id, @date, @date.next_week.yesterday], :order => :date}
        @checkings = @view_cancelled ? Checking.all(options) : Checking.actives.all(options)
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /checkings/new
  def new
    if !current_user.employee.nil?
      @checking  = Checking.new
      @employees = current_user.employee.subordinates
    else
      error_access_page(403)
    end
  end
  
  # POST /checkings
  def create
    params[:checking][:user_id] = current_user.id
    @checking  = Checking.new(params[:checking])
    @employees = current_user.employee.subordinates
    
    if @checking.save
      flash[:notice] = "Pointage ajout&eacute; avec succ&eacute;s"
      redirect_to checkings_path({:date => params[:checking][:date], :employee_id => params[:checking][:employee_id]})
    else
      render :action => "new"
    end
  end
  
  # GET /checkings/:id
  def edit
    if !current_user.employee.nil?
      @checking = Checking.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  # GET /checkings/:id/override_form
  def override_form
    if !current_user.employee.nil?
      @checking = Checking.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  # PUT /checkings/:id
  def update
    @checking = Checking.find(params[:id])
    if @checking.update_attributes(params[:checking])
      flash[:notice] = "Pointage modifi&eacute; avec succ&eacute;s"
      redirect_to checkings_path(:date => @checking.date, :employee_id => @checking.employee_id)
    else
      render :action => "edit"
    end
  end
  
  # PUT /checkings/:id/override
  def override
    @checking = Checking.find(params[:id])
    @checking.attributes = params[:checking]
    if @checking.override
      flash[:notice] = "Pointage corrigé avec succ&eacute;s"
      redirect_to checkings_path(:date => @checking.date, :employee_id => @checking.employee_id)
    else
      render :action => "override_form"
    end
  end
  
  # DELETE /checkings/:id
  def destroy
    @checking = Checking.find(params[:id])
    @checking.destroy
    redirect_to checkings_path
  end
  
  # GET /checkings/:id/cancel
  def cancel
    @checking = Checking.find(params[:id])
    @checking.cancel
    redirect_to checkings_path
  end
  
end
