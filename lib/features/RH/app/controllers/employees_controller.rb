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
    
    @employee = Employee.new(params[:employee])
    @job = Job.new(params[:job])
    @job.save
    @employee.address = Address.new(params[:address])
    params[:numbers].each do |number|
      @employee.numbers << Number.new(number[1]) unless number[1].nil? or number[1]==""
    end
    @employee.iban = Iban.new(params[:iban])
    
    respond_to do |format|
      if @employee.save
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
    @iban = @employee.iban
    @numbers = @employee.numbers
    @address = @employee.address
    
    
    for i in params[:numbers]
      if @employee.numbers[i[0].to_i].nil?
        @employee.numbers[i[0].to_i] =  Number.new(i[1]) unless i[1].nil? or i[1]=="" 
        @employee.save
      else  
        @employee.numbers[i[0].to_i].update_attributes(i[1]) unless i[1].nil? or i[1]==""
      end
    end 
    
    @employee.numbers.each_with_index do |id|
      if params[:numbers][id[1].to_s].nil?
        @employee.numbers[id[1]].destroy
      end
    end
    @employee.iban.update_attributes(params[:iban]) 
    @employee.address.update_attributes(params[:address])
    respond_to do |format|
      if @employee.update_attributes(params[:employee])
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
