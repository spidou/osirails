class JobContractsController < ApplicationController

  helper :documents

# GET /employees/1/edit
  def edit
   @employee =  Employee.find(params[:employee_id])
   @job_contract = @employee.job_contract 
  end

# GET /employees/1/show  
  def show
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
  end
# PUT /employees/1/update  
  def update
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    @salaries = @job_contract.salaries
     
    if params[:salaries]['type']['value'] == "Net"
      tmp = params[:salaries]['salary'].to_f/0.8
      params[:salaries]['salary'] = tmp
    end
   # small hack to bring out the date in the date select without referent object 
   # m= params[:premia]['date']['(2i)'] 
   # d= params[:premia]['date']['(3i)'] 
   # y= params[:premia]['date']['(1i)'] 
   # params[:premia]['date'] = "#{m}/#{d}/#{y}".to_date
   params[:job_contract]['end_date'] = nil if params[:job_contract]['end_date'].nil?
    if @job_contract.update_attributes(params[:job_contract]) and @salaries << Salary.create(params[:salaries]) 
      flash[:notice] = ' Le contrat de travail de ' + @employee.fullname + ' a été modifié avec succés.'
      redirect_to(@employee) 
    else
      render :action => "edit" 
    end
  end
end
