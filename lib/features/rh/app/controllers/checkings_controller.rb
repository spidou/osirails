class CheckingsController < ApplicationController


  def index
    if !current_user.employee.nil?
      @employees = current_user.employee.subordinates
      params[:employee_id]||= @employees.first
      params[:date]||= Date.today.monday
            
      unless params[:employee_id].nil?
        emp_id = params[:employee_id].to_i
        week_start = params[:date].to_date
        week_end = params[:date].to_date.next_week.yesterday
        @checkings = Checking.all(:conditions => ["employee_id =? and date >=? and date <=?", emp_id, week_start, week_end], :order => :date)
      end
    else
      error_access_page(403)
    end
  end
  
  def new
    if !current_user.employee.nil?
      @checking = Checking.new
      @employees = current_user.employee.subordinates
    else
      error_access_page(403)
    end
  end
  
  def create
    params[:checking][:user_id] = current_user.id
    @checking = Checking.new(params[:checking])
    @employees = current_user.employee.subordinates
    
    if @checking.save
      flash[:notice] = "Pointage ajout&eacute; avec succ&eacute;s"
      redirect_to checkings_path({:date => Date.today.monday, :employee_id => params[:checking][:employee_id]})
    else
      render :action => "new"
    end
  end
  
  def edit
    if !current_user.employee.nil?
      @checking = Checking.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  def update
    @checking = Checking.find(params[:id])
    
    if @checking.update_attributes(params[:checking])
      flash[:notice] = "Pointage modifi&eacute; avec succ&eacute;s"
      redirect_to checkings_path({:date => Date.today.monday, :employee_id => @checking.employee_id})
    else
      render :action => "new"
    end
  end
  
end
