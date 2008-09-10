class EmployeesController < ApplicationController
  helper :salaries, :documents
  
  method_permission(:list => ["show"])
  
  # GET /employees
  # GET /employees.xml
  def index
    if Employee.can_list?(current_user)
    # raise params.inspect
      params[:collection].nil? ?  @employees = Employee.active_employees : @employees = Employee.find(:all) 
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
      @iban = @employee.iban
      @numbers = @employee.numbers
      @address = @employee.address
      @jobs = @employee.jobs
      
      @job_contract = @employee.job_contract
    else
      error_access_page(403)
    end  
  end

  # GET /employees/new
  # GET /employees/new.xml
  def new
    if Employee.can_add?(current_user)
      @employee = Employee.new
      @job = Job.new
      @services = Service.find(:all)
      @jobs = Job.find(:all)
      @employee.address = Address.new
      @address = @employee.address
    else
      error_access_page(403)
    end
  end

  # GET /employees/1/edit
  def edit
    if Employee.can_edit?(current_user)  
      @employee = Employee.find(params[:id])
      @services = Service.find(:all)
      @job = Job.new
      @jobs = Job.find(:all)    
      @iban = @employee.iban
      @numbers = @employee.numbers
      @address = @employee.address
    else
      error_access_page(403)
    end
  end

  # POST /employees
  # POST /employees.xml
  def create
    if Employee.can_add?(current_user) 
      @services = Service.find(:all)
      @jobs = Job.find(:all) 
      
      # put numbers another place for a separate création
      params[:numbers] = params[:employee]['numbers']
      params[:employee].delete('numbers')
      
      # create employees ressources
      @employee = Employee.new(params[:employee])
      @job = Job.new(params[:job]) 
      @employee.address = Address.new(params[:address])
      @employee.iban = Iban.new(params[:iban])
      params[:numbers].each_value do |number|
        number['visible'] = false if number['visible'].nil?
        @employee.numbers << Number.new(number) unless number.blank?
      end
      
      
      
      # save or show errors 
      if @employee.save and job == true
        
        # save job and employees
        unless params[:job].nil?
          job = @job.save
        else
          job = true   
        end  
        
        # configure the employee as a responsable of his services if responsable is checked
        unless params[:responsable].nil?
          params[:responsable].each_key do |rep|
            @responsable = EmployeesService.find(:all, :conditions => ["employee_id=? and service_id=?",@employee.id,rep ])
            @responsable[0].update_attributes({:responsable => 1}) 
          end
        end  
        
        flash[:notice] = 'L&apos;employée a été crée avec succés.'
        redirect_to(@employee)
      else
        params[:employee]['numbers'] = params[:numbers]
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
   
      @employee = Employee.find(params[:id])
      @services = Service.find(:all)
      @jobs = Job.find(:all)
      @job = Job.new(params[:job]) 
      @iban = @employee.iban
      @numbers_reloaded||= nil
      @numbers_reloaded.nil? ? @numbers = @employee.numbers : @numbers = @numbers_reloaded
      @address = @employee.address
      
      # put numbers another place for a separate création
      params[:numbers] = params[:employee]['numbers']
      params[:employee].delete('numbers')
      # add or update numbers who have been send to the controller
      
      params[:numbers].each_key do |i|
        if @employee.numbers[i.to_i].nil?
          params[:numbers][i]['visible'] = false if params[:numbers][i]['visible'].nil?
          @employee.numbers[i.to_i] =  Number.new(params[:numbers][i]) unless params[:numbers][i].nil? or params[:numbers][i].blank?
        else
          params[:numbers][i]['visible'] = false if params[:numbers][i]['visible'].nil?  
          @employee.numbers[i.to_i].update_attributes(params[:numbers][i]) unless params[:numbers][i].nil? or params[:numbers][i].blank?
        end
      end 
      
      # TODO do not forget to delete this if do not use to remove numbers using visual effects
      # numbers_ids = []
      # @employee.numbers.each do |number|
      #   numbers_ids << number[:id]
      # end
      # param[:numbers].each do |i|
      #   params[:numbers][i].destroy unless numbers_ids.include?(f['id'].to_i)
      # end
      
      # prepare the address params hash  
      params[:address] = {}
      params[:address]['city_name'] = params[:employee]['address']['city']['name'] 
      params[:address]['zip_code'] = params[:employee]['address']['city']['zip_code']
      params[:address]['country_name'] = params[:employee]['address']['country']['name']
      params[:address]['address1'] = params[:employee]['address']['address1']
      params[:address]['address2'] = params[:employee]['address']['address2']
      params[:employee].delete('address')
      
      # update attributes of employees ressources
      @employee.iban.update_attributes(params[:iban]) 
      @employee.address.update_attributes(params[:address])
      
      # save or show errors
      if @employee.update_attributes(params[:employee])
        
        # destroy all responsables
        @responsable = EmployeesService.find(:all, :conditions => ["employee_id=?",params[:id]])
        @responsable.each do |r|
          r.update_attributes({:responsable => 0})
        end
        
        # destroy all services and jobs if there's no checked checkbox
        params[:employee]['service_ids']||= [] 
        params[:employee]['job_ids']||= []
        
        # destroy the numbers that have been deleted in the update view
        unless  params[:deleted_numbers].nil?
          params[:deleted_numbers].each_value do |i|
            @employee.numbers.each_index do |j|
              @employee.numbers[j].destroy if  @employee.numbers[j]['id'].to_s == i.to_s
            end
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
        @numbers.each_with_index do |number,index|
          unless params[:deleted_numbers].nil?
            params[:deleted_numbers].each_value do |j|
               @numbers[index]['number']= "deleted" if @numbers[index]['id'].to_s == j.to_s  
            end
          end  
        end
        
        @numbers_reloaded = @numbers
        params[:employee]['numbers'] = params[:numbers]

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
  

end
