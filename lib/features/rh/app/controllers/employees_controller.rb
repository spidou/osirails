class EmployeesController < ApplicationController
  helper :salaries, :job_contract, :documents
  before_filter :load_collections, :only => [:new, :create, :edit, :update, :show]  
  method_permission :list => ["show"]
  
  # GET /employees
  def index
    paginate_options = { :page => params[:page], :per_page => Employee::EMPLOYEES_PER_PAGE }
    @employees = params['all_employees'] || false ? Employee.all.paginate(paginate_options) : Employee.actives.paginate(paginate_options)
  end
  
  # GET /employees/:id
  def show
    @employee = Employee.find(params[:id])

    url     = @employee.avatar.path(:thumb)
    options = {:filename => @employee.avatar_file_name, :type => @employee.avatar_content_type, :disposition => 'inline'}
    
    respond_to do |format|
      format.html
      format.jpg { send_data(File.read(url), options) }
      format.png { send_data(File.read(url), options) }
    end
  end
  
  # GET /employees/new
  def new
    @employee = Employee.new
    @employee.numbers.build
    @employee.address = Address.new
  end
  
  # GET /employees/:id/edit
  def edit
    @employee = Employee.find(params[:id])
  end
  
  # POST /employees
  def create
    # regroupe the two parts of social security number
    params[:employee][:social_security_number] = params['social_security_number'].values.join " "
    params.delete('social_security_number')
    
    @employee = Employee.new(params[:employee])

    if @employee.save
      flash[:notice] = "L'employé(e) a été créé(e) avec succés."
      redirect_to @employee
    else
      render :action => "new"
    end
  end
  
  # PUT /employees/:id
  def update
    @employee = Employee.find params[:id]
    @address  = @employee.address

    # regroupe the two parts of social security number
    params[:employee][:social_security_number] = params['social_security_number'].values.join " "
    params.delete('social_security_number')
    
    # destroy all jobs if the params is nil
    params[:employee]['job_ids'] ||= []

    if @employee.update_attributes params[:employee]
      flash[:notice] = "L'employé(e) a été modifié(e) avec succés."
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
  
  private
    def load_collections
      @jobs     = Job.all
      @services = Service.all
    end
    
end
