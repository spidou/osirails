class CheckingsController < ApplicationController
  helper :employees,:numbers
  
  before_filter :define_date,       :only => [ :index, :new, :context_menu ]
  before_filter :find_as_employee,  :only => [ :index, :new, :create, :edit, :update, :destroy, :context_menu ]
  
  # GET /checkings
  def index
    @subordinates = @as_employee ? @as_employee.subordinates : current_user.employee.subordinates
  end
  
  # GET /checkings/new?employee_id=:employee_id&date=:date
  def new
    return error_access_page(400) if params[:employee_id].blank?
    
    @employee = Employee.find(params[:employee_id])
    
    if @checking = @employee.checkings.first(:conditions => ['date = ?', @date])
      redirect_to :action => 'edit', :id => @checking.id, :as_employee_id => @as_employee_id
    else
      @checking = @employee.checkings.build(:date => @date)
    end
  end
  
  # PUT /checkings
  def create
    @checking = Checking.new(:employee_id => params[:checking].delete(:employee_id), :date => params[:checking].delete(:date))
    @checking.attributes = params[:checking]
    @employee = @checking.employee
    @date = @checking.date
    
    if @checking.save
      flash[:notice] = "Le pointage a été créé avec succès."
      redirect_to checkings_path(:employee_id => @employee.id, :date => @date, :as_employee_id => @as_employee_id)
    else
      render :action => 'new'
    end
  end
  
  # GET /checkings/:id/edit
  def edit #TODO check if current_employee is really a responsible of the @employee
    @checking = Checking.find(params[:id])
    @employee = @checking.employee
    @date = @checking.date
  end

  # POST /checkings/:id
  def update
    @checking = Checking.find(params[:id])
    @employee = @checking.employee
    @date = @checking.date
    
    if @checking.update_attributes(params[:checking])
      flash[:notice] = "Le pointage a été modifié avec succès."
      redirect_to checkings_path(:employee_id => @employee.id, :date => @date, :as_employee_id => @as_employee_id)
    else
      render :action => 'edit'
    end
  end

  # DELETE /checkings/:id
  def destroy
    @checking = Checking.find(params[:id])
    unless @checking.destroy
      flash[:error] = "Une erreur est survenue à la suppression du pointage"
    else    
      flash[:notice] = "Le pointage a été supprimé avec succès."    
    end
    redirect_to :back
  end
  
  private
    def define_date
      @date = (params[:date] || Date.today).to_date
    end
    
    def find_as_employee
      @as_employee = as_employee_id? ? Employee.find(params[:as_employee_id]) : nil
      @as_employee_id = @as_employee ? @as_employee.id : nil
    end
    
    def as_employee_id?
      !params[:as_employee_id].blank?
    end
end  
