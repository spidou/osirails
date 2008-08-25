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
    @salaries = @job_contract.salaries
    @employee = Employee.find(@job_contract.employee_id)
    @premia = @employee.premia
     
    if params[:salaries]['type']['value'] == "Net"
      tmp = params[:salaries]['salary'].to_f/0.8
      params[:salaries]['salary'] = tmp
    end
   # small hack to bring out the date in the date select without referent object 
   # m= params[:premia]['date']['(2i)'] 
   # d= params[:premia]['date']['(3i)'] 
   # y= params[:premia]['date']['(1i)'] 
   # params[:premia]['date'] = "#{m}/#{d}/#{y}".to_date

    respond_to do |format|
      if @job_contract.update_attributes(params[:job_contract]) and @salaries << Salary.create(params[:salaries]) and @premia << Premium.create(params[:premia]) 
        flash[:notice] = ' Le contrat de travail de ' + @employee.fullname + ' a été modifié avec succés.'
        format.html { redirect_to(@employee) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
