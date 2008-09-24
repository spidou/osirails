class JobContractsController < ApplicationController

  helper :documents

# GET /employees/1/edit
  def edit
     
    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract 
  end

# GET /employees/1/show  
  def show
    
    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
  end
# PUT /employees/1/update  
  def update
    
    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    @salaries = @job_contract.salaries
     
    if params[:salaries]['type']['value'] == "Net"
      tmp = params[:salaries]['salary'].to_f/0.8
      params[:salaries]['salary'] = tmp
    end
    
     if Document.can_add?(current_user)
        if params[:new_document_number]["value"].to_i > 0
          documents = params[:job_contract][:documents].dup
          @document_objects = Document.create_all(documents, @employee)
        end
        document_params_index = 0
        params[:new_document_number]["value"].to_i.times do |i|
          params[:job_contract][:documents]["#{document_params_index += 1}"] = params[:job_contract][:documents]["#{i + 1}"] unless params[:job_contract][:documents]["#{i + 1}"][:valid] == "false"
        end
        ## Test if all documents enable are valid
        unless @document_objects.nil?
          @document_objects.size.times do |i|
            @error = true unless @document_objects[i].valid?
          end
          ## Reaffect document number
        params[:new_document_number]["value"]  = @document_objects.size
        end
      end
      
      
      # delete the documents in params
      params[:job_contract].delete('documents')
    
   # small hack to bring out the date in the date select without referent object 
   # m= params[:premia]['date']['(2i)'] 
   # d= params[:premia]['date']['(3i)'] 
   # y= params[:premia]['date']['(1i)'] 
   # params[:premia]['date'] = "#{m}/#{d}/#{y}".to_date
   params[:job_contract]['end_date'] = nil if params[:job_contract]['end_date'].nil?
    if @job_contract.update_attributes(params[:job_contract]) and @salaries << Salary.create(params[:salaries]) 
       
       # save the employee's documents
        unless params[:new_document_number].nil?
          if params[:new_document_number]["value"].to_i > 0
            @document_objects.each do |document|
              document.save
              @employee.documents << document
              document.create_thumbnails
            end
          end
        end
        
      flash[:notice] = ' Le contrat de travail de ' + @employee.fullname + ' a été modifié avec succés.'
      redirect_to(@employee) 
    else
      render :action => "edit" 
    end
  end
end
