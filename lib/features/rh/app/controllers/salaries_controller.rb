class SalariesController < ApplicationController  
  helper :employees, :numbers
  before_filter :verify_presence_of_job_contract, :only => [:new, :create]
  
  # GET /employees/:employee_id/index
  def index
    @employee = Employee.find(params[:employee_id])
    @salaries = @employee.job_contracts.all(:order => 'start_date DESC, created_at DESC').map{|j| [j, j.salaries]}
  end
  
  def new
    @salary = @employee.job_contract.salaries.build
  end
  
  def create
    @salary = @employee.job_contract.salaries.build(params[:salary])
    
    if @salary.valid?
      @salary.save
      flash[:notice] = "Le salaire a été modifié avec succès."
      redirect_to(@employee)
    else
      render :action => :new
    end
  end
  
  private
  
    def verify_presence_of_job_contract
      @employee = Employee.find(params[:employee_id])
      error_access_page(400) unless @employee.job_contract
    end
  
end
