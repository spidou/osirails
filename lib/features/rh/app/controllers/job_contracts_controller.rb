class JobContractsController < ApplicationController
  
  # GET /employees/:id/job_contract/edit
  def edit
    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
  end

  # PUT /employees/:id/job_contract/update  
  def update
    @document_controller = Menu.find_by_name('documents')

    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    
    params[:job_contract]['end_date'] = nil if params[:job_contract]['end_date'].nil?
    
    params[:job_contract]['employee_state_id'] = params[:job_contract]['employee_state_inactive'] if params[:job_contract]['employee_state_id'].nil?
    params[:job_contract].delete('employee_state_inactive') unless params[:job_contract]['employee_state_inactive'].nil?
    
#    if params[:salaries].nil?
#      salary_validate = true
#    else
#      @salary = Salary.new(params[:salaries]) unless params[:salaries].nil?
#      salary_validate = @salary.save 
#    end

    # put at null the departure date if there's no departure param
    @job_contract.departure = nil if params[:job_contract]['departure(3i)'].nil?

    if @job_contract.update_attributes(params[:job_contract]) # and  salary_validate  and @error==false
      
      # @job_contract.salaries << @salary unless @salary.nil?
        
      flash[:notice] = ' Le contrat de travail de ' + @employee.fullname + ' a été modifié avec succés.'
      redirect_to(@employee) 
    else
      render :action => "edit" 
    end
  end
  
end
