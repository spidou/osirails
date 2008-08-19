class JobContractsController < ApplicationController

# GET /employees/1/edit
  def edit
    @job_contract = JobContract.find(params[:id])
    @employee = Employee.find(@job_contract.employee_id)
  end

# GET /employees/1/show  
  def show
    @job_contract = JobContract.find(params[:id])
    @employee = Employee.find(@job_contract.employee_id)
  end
# PUT /employees/1/update  
  def update
    @job_contract = JobContract.find(params[:id])
    @employee = Employee.find(@job_contract.employee_id)
    respond_to do |format|
      if @job_contract.update_attributes(params[:job_contract])
        flash[:notice] = ' Le contrat de travail ' + @employee.fullname + ' a été modifié avec succés.'
        format.html { redirect_to(@employee) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
