class JobContractsController < ApplicationController
  helper :employees, :documents, :numbers
  
  before_filter :find_employee
  before_filter :find_or_build_job_contract, :only => [:edit, :update]
  
  # GET /employees/:employee_id/job_contracts
  def index
    @job_contracts = @employee.job_contracts.all(:order => 'start_date Desc, created_at DESC')
    @hide_selector_column = true
  end
  
  # GET /employees/:employee_id/job_contracts/new
  def new
    @job_contract = @employee.job_contracts.build
  end
  
  # POST /employees/:employee_id/job_contracts
  def create
    @job_contract = @employee.job_contracts.build(params[:job_contract])
    
    if @job_contract.valid?
      @employee.save
      @job_contract.save 
      flash[:notice] = 'Le contrat de travail a été modifié avec succès.'
      redirect_to(employee_job_contract_path(@employee, @job_contract))
    else
      render(:action => 'new')
    end
  end
  
  # GET /employees/:employee_id/job_contracts/:id/edit
  def edit
    @employee_departure ||= true if params['employee_departure']
  end
  
  # PUT /employees/:employee_id/job_contracts/:id  
  def update
    if @job_contract.update_attributes(params[:job_contract])
      flash[:notice] = 'Le contrat de travail a été modifié avec succès.'
      redirect_to(employee_job_contract_path(@employee, @job_contract))
    else
      @employee_departure = true if params['employee_departure']
      render(:action => 'edit')
    end
  end
  
  def find_employee
    @employee = Employee.find(params[:employee_id])
  end
  
  def find_or_build_job_contract
    #@job_contract = @employee.job_contracts.detect {|n| n.id == params[:id].to_i}
    @job_contract = @employee.job_contracts.find_by_id(params[:id]) || @employee.job_contracts.build
  end
end
