class JobContractController < ApplicationController
  helper :employees, :documents, :numbers
  
  # GET /employees/:employee_id/job_contract
  def show
    redirect_to :action => :edit
  end
  
  # GET /employees/:employee_id/job_contract/edit
  def edit
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
  end

  # PUT /employees/:employee_id/job_contract/update  
  def update

    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    
    params[:job_contract]['employee_state_id']||= params[:job_contract]['employee_state_inactive']
    params[:job_contract].delete('employee_state_inactive')

    if @job_contract.update_attributes(params[:job_contract])      
      flash[:notice] = 'Le contrat de travail a été modifié avec succès.'
      redirect_to(@employee) 
    else
      render :action => "edit" 
    end
  end
end
