class PremiaController < ApplicationController
  helper :employees, :numbers

  # GET /employees/:employee_id/premia
  def index
    @employee = Employee.find(params[:employee_id])
    @premia = @employee.employee_sensitive_data.premia
  end
  
  # GET /employees/:employee_id/premia/new
  def new
    @employee = Employee.find(params[:employee_id])
    @premium = Premium.new
  end
  
  # POST /employees/:employee_id/premia
  def create
    @employee = Employee.find(params[:employee_id])
    @premia = @employee.employee_sensitive_data.premia
    @premium = Premium.new(params[:premium])
    if @premium.save 
      @premia << @premium
      flash[:notice] = ' La prime a été ajoutée avec succès.'
      redirect_to employee_premium_path(@employee, @premium)
    else
      render :action => "new"
    end
  end
end
