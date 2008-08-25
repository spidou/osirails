class PremiaController < ApplicationController

# GET /premia/1/index  
  def index
    params[:employee_id].nil? ? @employee = current_user.employee.id : @employee = params[:employee_id]
    @premia = Employee.find(@employee).premia
  end
  
# EDIT /premia/1/edit  
  def new
    @employee = Employee.find(params[:employee_id])
    @premium = Premium.new
  end
  
  def create
    @employee = Employee.find(params[:employee_id])
    @premia = @employee.premia
    
    if @premia << Premium.new(params[:premium])
      flash[:notice] = ' La prime a été ajoutée avec succés.'
      redirect_to(@employee)
    else
      render :action => "new"
    end
  end
end
