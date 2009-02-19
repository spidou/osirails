class EmployeesController < ApplicationController
  helper :salaries, :documents, :job_contracts

  # Callbacks
  before_filter :load_collections, :only => [:new, :create, :edit, :update]
  
  method_permission(:list => ["show"])
  
  # GET /employees
  # GET /employees.xml
  def index
    if Employee.can_list?(current_user)
      params['all_employees']||= false 
      params['all_employees'] ? @employees = Employee.find(:all) : @employees = Employee.active_employees 
    else
      error_access_page(403)
    end
  end

  # GET /employees/1
  # GET /employees/1.xml
  def show
    if Employee.can_list?(current_user)
    
      @premia_controller = Menu.find_by_name("premia")
      @job_contract_controller = Menu.find_by_name("job_contracts")
      
      @employee = Employee.find(params[:id])
      @numbers = @employee.numbers
      @address = @employee.address
      @jobs = @employee.jobs
      @services = @employee.services
      @job_contract = @employee.job_contract
      @documents = @employee.documents
    else
      error_access_page(403)
    end  
  end

  # GET /employees/new
  # GET /employees/new.xml
  def new
    if Employee.can_add?(current_user)
      
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.new

      @employee.numbers.build


      @employee.address = Address.new
      @address = @employee.address
      @documents = @employee.documents
    else
      error_access_page(403)
    end
  end

  # GET /employees/1/edit
  def edit
    if Employee.can_edit?(current_user)
    
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.find(params[:id]) 
      @numbers = @employee.numbers
      @address = @employee.address
      @documents =@employee.documents
      
    else
      error_access_page(403)
    end
  end

  # POST /employees
  # POST /employees.xml
  def create
    if Employee.can_add?(current_user)
      
      @document_controller = Menu.find_by_name('documents')
 
     
       # @error is use to know if all form are valids
      #@error = false
      
      employee = params[:employee].dup
      
      ## put numbers another place for a separate création
      ## params[:numbers] = employee['numbers']
      ## employee.delete('numbers')
      
      # regroupe the two parts of social security number
      employee[:social_security_number] =  params['social_security_number']['0'] + " " + params['social_security_number']['1']
      params.delete('social_security_number')
      
      # docs = employee.delete('documents')
      
      # create employees ressources
      @employee = Employee.new(employee)


      # @employee.address = Address.new(params[:address])
      # @documents = @employee.documents
      
      ## params[:numbers].each_value do |number|
      ##  number['visible'] = false if number['visible'].nil?
      ##  @employee.numbers << Number.new(number) unless number.blank?
      ##end
      
 #     if Document.can_add?(current_user, @employee.class)
#        if params[:new_document_number]["value"].to_i > 0
#          documents = params[:employee][:documents].dup
#          @document_objects = Document.create_all(documents, @employee)
#        end
#        document_params_index = 0
#        params[:new_document_number]["value"].to_i.times do |i|
#          params[:employee][:documents]["#{document_params_index += 1}"] = params[:employee][:documents]["#{i + 1}"] unless params[:employee][:documents]["#{i + 1}"][:valid] == "false"
#        end
#        ## Test if all documents enable are valid
#        unless @document_objects.nil?
#          @document_objects.size.times do |i|
#            @error = true unless @document_objects[i].valid?
#          end
#          ## Reaffect document number
#        params[:new_document_number]["value"]  = @document_objects.size
#        end
#      end
      

      # save or show errors 
      if @employee.save #and @error == false # and job == true
        
        # save the employee's documents
        #unless params[:new_document_number].nil? and !Document.can_add?(current_user) and @employee.class
          #if params[:new_document_number]["value"].to_i > 0
            #@document_objects.each do |document|
              #if document.save == true
              #  @employee.documents << document
              #  document.create_thumbnails
              #  document.create_preview_format
              #else
              #  @error = true
              #end
            #end
          #end
        #end
        
        # configure the employee as a responsable of his services if responsable is checked
        unless params[:responsable].nil?
          params[:responsable].each_key do |rep|
            @responsable = EmployeesService.find(:all, :conditions => ["employee_id=? and service_id=?",@employee.id,rep ])
            @responsable[0].update_attributes({:responsable => 1})  unless @responsable[0].nil?
          end
        end  
        
        flash[:notice] = 'L&apos;employée a été crée avec succés.'
        redirect_to(@employee)
      else
        ## params[:employee]['numbers'] = params[:numbers]
       # params[:employee]['documents'] = docs
        
        render :action => "new" 
      end
    else
      error_access_page(403)
    end  
  end

  # PUT /employees/1
  # PUT /employees/1.xml
  def update
    if Employee.can_edit?(current_user)
      
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.find(params[:id])

      @address = @employee.address

      @error = false
      @documents = @employee.documents
      @errors_messages = []

      
      # regroupe the two parts of social security number
      params[:employee][:social_security_number] =  params['social_security_number']['0'] + " " + params['social_security_number']['1']
      params.delete('social_security_number')


      
      # TODO do not forget to delete this if do not use to remove numbers using visual effects
      # numbers_ids = []
      # @employee.numbers.each do |number|
      #   numbers_ids << number[:id]
      # end
      # param[:numbers].each do |i|
      #   params[:numbers][i].destroy unless numbers_ids.include?(f['id'].to_i)
      # end
      
      # prepare the address params hash  
 #     params[:address] = {}
 #     params[:address]['city_name'] = params[:employee]['address']['city'].nil? ? "" : params[:employee]['address']['city']['name']
#      params[:address]['zip_code'] = params[:employee]['address']['city'].nil? ? "" : params[:employee]['address']['city']['zip_code']
#      params[:address]['country_name'] = params[:employee]['address']['country']['name']
#      params[:address]['address1'] = params[:employee]['address']['address1']
#      params[:address]['address2'] = params[:employee]['address']['address2']
#      params[:employee].delete('address')
      
      # update attributes of employees ressources
#      @employee.iban.update_attributes(params[:iban]) 

#      @employee.address.update_attributes(params[:address])
      

#      if Document.can_add?(current_user, @employee.class)
#        if params[:new_document_number]["value"].to_i > 0
#          documents = params[:employee][:documents].dup
#          @document_objects = Document.create_all(documents, @employee)
#        end
#        document_params_index = 0
#        params[:new_document_number]["value"].to_i.times do |i|
#          params[:employee][:documents]["#{document_params_index += 1}"] = params[:employee][:documents]["#{i + 1}"] unless params[:employee][:documents]["#{i + 1}"][:valid] == "false"
#        end
        ## Test if all documents enable are valid
#        unless @document_objects.nil?
#          @document_objects.size.times do |i|
#            @error = true unless @document_objects[i].valid?
#          end
          ## Reaffect document number
#        params[:new_document_number]["value"]  = @document_objects.size
#        end
#      end
      
      
      # delete the documents in params
#      docs = params[:employee].delete('documents')
      
      # destroy all services and jobs 
      params[:employee]['service_ids']||= [] 
      params[:employee]['job_ids']||= []

      # save or show errors
      if @employee.update_attributes(params[:employee])  and @error == false #and @number_error == false
        
        # save the employee's documents
#        unless params[:new_document_number].nil? and !Document.can_add?(current_user) and @employee.class
#          if params[:new_document_number]["value"].to_i > 0
#            @document_objects.each do |document|
#              if document.save == true
#                @employee.documents << document
#                document.create_thumbnails
#                document.create_preview_format
#              else
#                @error = true
#              end
#            end
#          end
#        end
        

        # destroy all responsables if there's no checked checkbox
        @responsable = EmployeesService.find(:all, :conditions => ["employee_id=?",params[:id]])
        EmployeesService.transaction do        
          @responsable.each do |r|
            r.update_attributes({:responsable => 0})
          end
        end
        


        
       
        
        # update responsable attribute of the employee's service 
        unless params[:responsable].nil?
          params[:responsable].each_key do |rep|
            @responsable = EmployeesService.find(:all, :conditions => ["employee_id=? and service_id=?",@employee.id,rep ])
            @responsable[0].update_attributes({:responsable => 1}) unless @responsable[0].nil?
          end
        end 
          
        flash[:notice] = ' L&apos;employée a été modifié avec succés.'
        
        redirect_to(@employee)
      else
        
#        params[:employee]['documents'] = docs
          
        render :action => "edit"
      end
    else
      error_access_page(403)
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.xml
  def destroy
    if Employee.can_delete?(current_user)
      @employee = Employee.find(params[:id])
      @employee.destroy
      
      redirect_to(employees_url)
    else
      error_access_page(403)
    end  
  end

  def load_collections
    @jobs = Job.find(:all)
    @services = Service.find(:all)
  end 
  

end
