class LeaveRequestsController < ApplicationController

  # GET /leave_requests
  # GET /leave_requests.xml
  def index
  
    @employee = current_user.employee
    
    if !@employee.nil?
      @index = true
      
      @leave_requests_to_check = LeaveRequest.find(:all, :conditions => ["status = ? AND employee_id IN (?)", LeaveRequest::STATUS_SUBMITTED, @employee.subordinates_and_himself], :order => "start_date, created_at DESC" )
      
      @leave_requests_to_notice = LeaveRequest.find(:all, :conditions => ["status = ?", LeaveRequest::STATUS_CHECKED], :order => "start_date, created_at DESC")
      
      @leave_requests_to_close = LeaveRequest.find(:all, :conditions => ["status = ?", LeaveRequest::STATUS_NOTICED], :order => "start_date, created_at DESC")
      
      @active_leave_requests = @employee.active_leave_requests
      
      @accepted_leave_requests = @employee.accepted_leave_requests
      
      @refused_leave_requests = @employee.refused_leave_requests      
      
      @refused_by_me_leave_requests = LeaveRequest.find(:all, :conditions => ["(status = ? AND responsible_id = ?) OR (status = ? AND director_id = ?) AND start_date > ?", LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE, @employee.id, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR, @employee.id, Date.today], :order => "start_date, created_at DESC" )        
      
      @leave_requests_to_treat = true if ((@leave_requests_to_check.size > 0 and LeaveRequest.can_check?(current_user)) or (@leave_requests_to_notice.size > 0 and LeaveRequest.can_notice?(current_user)) or (@leave_requests_to_close.size > 0 and LeaveRequest.can_close?(current_user)) or @refused_by_me_leave_requests.size > 0)
      
    end
  end

  # GET /leave_requests/1
  # GET /leave_requests/1.xml
  def show
    @leave_request = LeaveRequest.find(params[:id])
    
    @employee = @leave_request.employee
    
    @start_date = @leave_request.start_date
    @end_date = @leave_request.end_date
    
  end

  # GET /leave_requests/new
  # GET /leave_requests/new.xml
  def new
    @employee = current_user.employee
    @employee_id = current_user.employee.id
    @leave_request = LeaveRequest.new
  end

  # GET /leave_requests/1/edit
  def edit
    @leave_request = LeaveRequest.find(params[:id])
  end

  # POST /leave_requests
  # POST /leave_requests.xml
  def create
    @leave_request = LeaveRequest.new(params[:leave_request])    

    if @leave_request.submit
      flash[:notice] = 'La demande de congée a été créée avec succès et transférée à votre reponsable.'
      redirect_to(@leave_request)
    else
      render :action => "new"
    end    
  end

  # PUT /leave_requests/1
  # PUT /leave_requests/1.xml
  def update
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.update_attributes(params[:leave_request])
      flash[:notice] = "La réponse a été envoyée avec succès"
      redirect_to(leave_requests_url)
    else
      render :action => "edit"
    end     
  end
  
  def check
    @leave_request = LeaveRequest.find(params[:id])
    
    @leave_request.attributes = params[:leave_request]
    if @leave_request.check
      flash[:notice] = "La réponse a été envoyée avec succès"
      redirect_to(leave_requests_url)
    else
      render :action => "edit"
    end  
  end
  
  def notice
    @leave_request = LeaveRequest.find(params[:id])

    @leave_request.attributes = params[:leave_request]
    if @leave_request.notice
      flash[:notice] = "La réponse a été envoyée avec succès"
      redirect_to(leave_requests_url)
    else
      render :action => "edit"
    end  
  end
  
  def close
    @leave_request = LeaveRequest.find(params[:id])

    @leave_request.attributes = params[:leave_request]
    if @leave_request.close 
      flash[:notice] = "La réponse a été envoyée avec succès et un congé a été généré"
      redirect_to(leave_requests_url)
    else
      render :action => "edit"
    end  
  end

  # DELETE /leave_requests/1
  # DELETE /leave_requests/1.xml
  def destroy
    @employee = current_user.employee
    @leave_request = LeaveRequest.find(params[:id])
    
    case @leave_request.status_was
      when LeaveRequest::STATUS_SUBMITTED, LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE
        @leave_request.responsible_id = @employee.id
      when LeaveRequest::STATUS_CHECKED
        @leave_request.observer_id = @employee.id
      when LeaveRequest::STATUS_NOTICED, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR
        @leave_request.director_id = @employee.id
    end
    @leave_request.cancelled_by = @employee.id
    @leave_request.cancel

    redirect_to(leave_requests_url)
  end
  
  def accepted
    @accepted_leave_requests = LeaveRequest.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE, :conditions => ["status = ? AND employee_id = ?", LeaveRequest::STATUS_CLOSED, current_user.employee.id], :order => "start_date, created_at DESC" )
  end
  
  def refused
    @refused_leave_requests = LeaveRequest.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE, :conditions => ["status IN (?) AND employee_id = ?", [LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE,LeaveRequest::STATUS_REFUSED_BY_DIRECTOR], current_user.employee.id], :order => "start_date, created_at DESC" )
  end
  
  def cancelled
    @cancelled_leave_requests = LeaveRequest.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE, :conditions => ["status = ?", LeaveRequest::STATUS_CANCELLED], :order => "start_date, created_at DESC" )
  end
  
end
