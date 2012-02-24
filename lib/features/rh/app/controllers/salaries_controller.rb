class SalariesController < ApplicationController  
  helper :employees, :numbers
  before_filter :verify_presence_of_job_contract, :only => [:new, :create]
  
  # GET /employees/:employee_id/salaries
  def index
    @employee = Employee.find(params[:employee_id])
    @salaries = @employee.job_contracts.all(:order => 'start_date DESC, created_at DESC').map{|j| [j, j.salaries]}
  end
  
  # GET /employees/:employee_id/salaries/new
  def new
    @salary = @employee.job_contract.salaries.build
  end
  
  # PUT /employees/:employee_id/salaries
  def create
    @salary = @employee.job_contract.salaries.build(params[:salary])
    
    if @salary.save
      flash[:notice] = "Le salaire a été modifié avec succès."
      redirect_to employee_salary_path(@employee, @salary)
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
