class LeavesController < ApplicationController

  before_filter :load_collections, :only => [:new, :create, :edit, :update] 

  # GET /employees/:employee_id/leaves
  def index
    @employee        = Employee.find params[:employee_id]
    @year            = (params[:leave_year].nil?)? Employee.leave_year_start_date.year : params[:leave_year].to_i
    @view_cancelled  = params[:cancelled] || false  # if true permit to see cancelled leaves
    @leaves          = @employee.get_leaves_for_choosen_year(@year, @view_cancelled)
    
    respond_to do |format|
      format.js   {render :action => "index", :layout => false}
      format.html {render :action => "index"}
    end
  end
  
  # GET /employees/:employee_id/leaves/new
  def new
    @leave    = Leave.new
    @employee = Employee.find params[:employee_id]
  end
  
  # POST /employees/:employee_id/leaves
  def create
    @leave    = Leave.new params[:leave]
    @employee = Employee.find params[:employee_id]
    @leave.employee = @employee
    
    if @leave.save
      flash[:notice] = "Le congé a été ajouté avec succès"
      redirect_to employee_leaves_path(@employee)
    else
      render :action => :new 
    end
    
  end
  
  # GET /employees/:employee_id/leaves/:id
  def edit
    @leave    = Leave.find params[:id]
    @employee = @leave.employee
  end
  
  # PUT /employees/:employee_id/leaves/:id
  def update
    @leave    = Leave.find(params[:id])
    @employee = @leave.employee
    
    if @leave.update_attributes params[:leave] 
      flash[:notice] = "La congé a été modifié avec succès"
      redirect_to employee_leaves_path(@employee)
    else
      render :action => :edit
    end
  end
  
  # GET /employees/:employee_id/leaves/:id/cancel
  def cancel
    @leave = Leave.find params[:id]
    unless @leave.cancel
      flash[:error] = "Une erreur est survenue à l'annulation du congé"
    end
    redirect_to employee_leaves_path
  end
  
  # DELETE /employees/:employee_id/leaves/:id
  def destroy
    @leave = Leave.find params[:id]
    unless @leave.destroy
      flash[:error] = "Une erreur est survenue à la suppression du congé"
    end
    redirect_to employee_leaves_path
  end
  
  def load_collections
    @leave_types = LeaveType.all
  end
end
