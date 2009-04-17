class PremiaController < ApplicationController

  # GET /employees/:employee_id/premia
  def index
    @employee = Employee.find(params[:employee_id])
    @premia = @employee.premia
  end
  
  # GET /employees/:employee_id/premia/new
  def new
    @employee = Employee.find(params[:employee_id])
    @premium = Premium.new
  end
  
  # POST /employees/:employee_id/premia
  def create
    @employee = Employee.find(params[:employee_id])
    @premia = @employee.premia
    @premium = Premium.new(params[:premium])
    if @premium.save 
      @premia << @premium
      flash[:notice] = ' La prime a &eacute;t&eacute; ajout&eacute;e avec succ&eacute;s.'
      redirect_to(@employee)
    else
      render :action => "new"
    end
  end
end
