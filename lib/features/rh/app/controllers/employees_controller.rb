class EmployeesController < ApplicationController
  helper :salaries, :job_contracts

  # Callbacks
  before_filter :load_collections, :only => [:new, :create, :edit, :update]
  
  method_permission(:list => ["show"])
  
  # GET /employees
  def index
    if Employee.can_list?(current_user)
      params['all_employees']||= false 
      params['all_employees'] ? @employees = Employee.find(:all) : @employees = Employee.active_employees 
    else
      error_access_page(403)
    end
  end

  # GET /employees/1
  def show
    if Employee.can_list?(current_user)
      @premia_controller = Menu.find_by_name("premia")
      @job_contract_controller = Menu.find_by_name("job_contracts")
      
      @employee = Employee.find(params[:id])
    else
      error_access_page(403)
    end  
  end

  # GET /employees/new
  def new
    if Employee.can_add?(current_user)
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.new
    else
      error_access_page(403)
    end
  end

  # GET /employees/1/edit
  def edit
    if Employee.can_edit?(current_user)
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.find(params[:id]) 
    else
      error_access_page(403)
    end
  end

  # POST /employees
  def create
    if Employee.can_add?(current_user)
      @document_controller = Menu.find_by_name('documents')
      
      employee = params[:employee].dup
      
      # regroupe the two parts of social security number
      employee[:social_security_number] =  params['social_security_number']['0'] + " " + params['social_security_number']['1']
      params.delete('social_security_number')
      
      @employee = Employee.new(employee)
      if @employee.save #and @error == false # and job == true
        
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
        render :action => "new" 
      end
    else
      error_access_page(403)
    end  
  end

  # PUT /employees/1
  def update
    if Employee.can_edit?(current_user)
      @document_controller = Menu.find_by_name('documents')
      
      @employee = Employee.find(params[:id])
      @error = false
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
      
      # destroy all services and jobs 
      params[:employee]['service_ids']||= [] 
      params[:employee]['job_ids']||= []

      # save or show errors
      if @employee.update_attributes(params[:employee]) and @error == false #and @number_error == false
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
        render :action => "edit"
      end
    else
      error_access_page(403)
    end
  end

  # DELETE /employees/1
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
