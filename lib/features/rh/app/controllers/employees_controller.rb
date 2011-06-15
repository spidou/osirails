class EmployeesController < ApplicationController
  helper :salaries, :job_contracts, :documents, :numbers, :address
  
  # GET /employees
  def index
    @hide_selector_column = true
    build_query_for(:employee_index)
  end
  
  # GET /employees/:id
  def show
    @employee = Employee.find(params[:id])

    url     = @employee.avatar.path(:thumb)
    options = { :filename => @employee.avatar_file_name, :type => @employee.avatar_content_type, :disposition => 'inline' }
    
    respond_to do |format|
      format.html
      format.jpg { send_data(File.read(url), options) }
      format.png { send_data(File.read(url), options) }
    end
  end
  
  # GET /employees/new
  def new
    @employee = Employee.new
  end
  
  # GET /employees/:id/edit
  def edit
    @employee = Employee.find(params[:id])
  end
  
  # POST /employees
  def create
    # group the two parts of social security number
    if params['social_security_number']
      params[:employee][:social_security_number] = params['social_security_number'].values.join(" ")
      params.delete('social_security_number')
    end
    error_access_page(401) if params[:employee][:employee_sensitive_data] && !EmployeeSensitiveData.can_add?(current_user)
    
    @employee = Employee.new(params[:employee])
  
    if @employee.save
      flash[:notice] = "L'employé(e) a été créé(e) avec succès."
      redirect_to @employee
    else
      render :action => "new"
    end
  end
  
  # PUT /employees/:id
  def update
    @employee = Employee.find(params[:id])
    @address  = @employee.employee_sensitive_data.address

    # group the two parts of social security number
    if params['social_security_number']
      params[:employee][:employee_sensitive_data][:social_security_number] = params['social_security_number'].values.join(" ")
      params.delete('social_security_number')
    end
    error_access_page(401) if params[:employee][:employee_sensitive_data] && !EmployeeSensitiveData.can_edit?(current_user)
    
    # destroy all jobs if the params is nil
    params[:employee]['job_ids'] ||= []
    
    if @employee.update_attributes(params[:employee])
      flash[:notice] = "L'employé(e) a été modifié(e) avec succès."
      redirect_to @employee
    else
      render :action => "edit"
    end
  end
  
  # DELETE /employees/:id
  def destroy
    @employee = Employee.find params[:id]
    unless @employee.destroy
      flash[:error] = "Une erreur est survenue à la suppression de l'employé(e)"
    end
    redirect_to employees_path
  end
end
