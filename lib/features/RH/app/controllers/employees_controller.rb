class EmployeesController < ApplicationController
  helper :salaries
  method_permission(:list => ["show"])
  
  # GET /employees
  # GET /employees.xml
  def index
    @employees = Employee.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.xml
  def show
    @employee = Employee.find(params[:id])
    @iban = @employee.iban
    @numbers = @employee.numbers
    @address = @employee.address
    @jobs = @employee.jobs
    # permissions
    @edit = self.can_edit?(current_user)
    @view = self.can_view?(current_user)
    @list = self.can_list?(current_user)
    
    @job_contract = @employee.job_contract
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @employee }
    end
  end

  # GET /employees/new
  # GET /employees/new.xml
  def new
    @employee = Employee.new
    @job = Job.new
    @services = Service.find(:all)
    @jobs = Job.find(:all)
#    @adress = @employee.adresse
#    @number_type = @employee.numbers
    
    
    # @civilties = Civility

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /employees/1/edit
  def edit
    @employee = Employee.find(params[:id])
    @services = Service.find(:all)
    @jobs = Job.find(:all)    
    @iban = @employee.iban
    @numbers = @employee.numbers
    @address = @employee.address

  end

  # POST /employees
  # POST /employees.xml
  def create
    # FIXME do not forget to resolve the  default selected value (numbers) of the create view (new.html.erb) 
    # instance_variable_set("@numbers",[]) 
    @services = Service.find(:all)
    @jobs = Job.find(:all) 
    
    # update employees ressources
    @employee = Employee.new(params[:employee])
    @job = Job.new(params[:job]) 
    @employee.address = Address.new(params[:address])
    params[:numbers].each do |number|
      @employee.numbers << Number.new(number[1]) unless number[1].nil? or number[1]==""
    end
    @employee.iban = Iban.new(params[:iban])
    
    # save job and employees
    unless params[:job].nil?
      @job.save ? job = true : job = false  
    end   
    respond_to do |format|
      if @employee.save and job == true
      
        # configure the employee as a responsable of his services if responsable is checked
        params[:responsable].each_key do |rep|
          @responsable = EmployeesService.find(:all, :conditions => ["employee_id=? and service_id=?",@employee.id,rep ])
          @responsable[0].update_attributes({:responsable => 1}) 
        end
        
        flash[:notice] = 'L&apos;employée a été crée avec succés.'
        format.html { redirect_to(@employee) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /employees/1
  # PUT /employees/1.xml
  def update
    @employee = Employee.find(params[:id])
    @services = Service.find(:all)
    @jobs = Job.find(:all) 
    @iban = @employee.iban
    @numbers = @employee.numbers
    @address = @employee.address
    
   
    
    # add or update numbers who have been send to the controller
    for i in params[:numbers]
      if @employee.numbers[i[0].to_i].nil?
        @employee.numbers[i[0].to_i] =  Number.new(i[1]) unless i[1].nil? or i[1]=="" 
        @employee.save
      else  
        @employee.numbers[i[0].to_i].update_attributes(i[1]) unless i[1].nil? or i[1]==""
      end
    end 
    
    # destroy the numbers that have been deleted in the update view
    @employee.numbers.each_with_index do |id|
      if params[:numbers][id[1].to_s].nil?
        @employee.numbers[id[1]].destroy
      end
    end
    
    # update attributes of employees ressources
    @employee.iban.update_attributes(params[:iban]) 
    @employee.address.update_attributes(params[:address])
    
    # destroy all services and jobs if there's no checked checkbox
    params[:employee]['service_ids']||= [] 
    params[:employee]['job_ids']||= []
    
    # destroy all responsables
    @responsable = EmployeesService.find(:all, :conditions => ["employee_id=?",params[:id]])
    @responsable.each do |r|
      r.update_attributes({:responsable => 0})
    end
    
    respond_to do |format|
      if @employee.update_attributes(params[:employee])
      
        # update responsable attribute of the employee's service 
        unless params[:responsable].nil?
          params[:responsable].each_key do |rep|
            @responsable = EmployeesService.find(:all, :conditions => ["employee_id=? and service_id=?",@employee.id,rep ])
            @responsable[0].update_attributes({:responsable => 1}) unless @responsable[0].nil?
          end
        end 
         
        flash[:notice] = ' L&apos;employée a été modifié avec succés.'
        format.html { redirect_to(@employee) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.xml
  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to(employees_url) }
      format.xml  { head :ok }
    end
  end
  

end
