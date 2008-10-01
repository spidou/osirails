class JobContractsController < ApplicationController

  helper :documents

# GET /employees/1/edit
  def edit

    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    @documents = @job_contract.documents 
  end

# GET /employees/1/show  
  def show
    
    @document_controller = Menu.find_by_name('documents')
    
    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    @documents = @job_contract.documents
  end
# PUT /employees/1/update  
  def update
  
    @document_controller = Menu.find_by_name('documents')

    @employee =  Employee.find(params[:employee_id])
    @job_contract = @employee.job_contract
    @documents = @job_contract.documents
    @error = false
    
    unless params[:salaries].nil? 
      if params[:salaries]['type']['value'] == "Net"
        tmp = params[:salaries]['salary'].to_f/0.8
        params[:salaries]['salary'] = tmp
      end
    end
    
    if Document.can_add?(current_user, @job_contract.class)
      if params[:new_document_number]["value"].to_i > 0
        documents = params[:job_contract][:documents].dup
        @document_objects = Document.create_all(documents, @job_contract)
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
    docs = params[:job_contract].delete('documents')
    
    params[:job_contract]['end_date'] = nil if params[:job_contract]['end_date'].nil?
    
    params[:job_contract]['employee_state_id'] = params[:job_contract]['employee_state_inactive'] if params[:job_contract]['employee_state_id'].nil?
    params[:job_contract].delete('employee_state_inactive') unless params[:job_contract]['employee_state_inactive'].nil?
    
    
    
    if params[:salaries].nil?
      salary_validate = true
    else
      @salary = Salary.new(params[:salaries]) unless params[:salaries].nil?
      salary_validate = @salary.save 
    end

    if @job_contract.update_attributes(params[:job_contract]) and  salary_validate and @error==false
    
      # put at null the departure date if the there's no departure param
      @job_contract.departure = nil if params[:job_contract]['departure(3i)'].nil?
      @job_contract.save
      
      @job_contract.salaries << @salary unless @salary.nil?
      # save the job_contract's documents
      unless params[:new_document_number].nil?
        if params[:new_document_number]["value"].to_i > 0
          @document_objects.each do |document|
            if (d = document.save) == true
              @job_contract.documents << document
              document.create_thumbnails
            else
              @error = true
              flash[:error] = d
            end
          end
        end
      end
        
      flash[:notice] = ' Le contrat de travail de ' + @employee.fullname + ' a été modifié avec succés.'
      redirect_to(@employee) 
    else
      params[:job_contract]['documents'] = docs
      render :action => "edit" 
    end
  end
end
