class LeaveRequestsController < ApplicationController
  
  # GET /leave_requests
  def index
    
    @employee = current_user.employee
    
    if !@employee.nil?
      @index = true
      
      @leave_requests_to_check = LeaveRequest.find(:all, :conditions => ["status = ? AND employee_id IN (?)", LeaveRequest::STATUS_SUBMITTED, @employee.subordinates_and_himself], :order => "start_date DESC" )
      
      @leave_requests_to_notice = LeaveRequest.find(:all, :conditions => ["status = ?", LeaveRequest::STATUS_CHECKED], :order => "start_date DESC")
      
      @leave_requests_to_close = LeaveRequest.find(:all, :conditions => ["status = ?", LeaveRequest::STATUS_NOTICED], :order => "start_date DESC")
      
      @active_leave_requests = @employee.active_leave_requests.find(:all, :limit => 5)
      
      @accepted_leave_requests = @employee.accepted_leave_requests.find(:all, :limit => 5)
      
      @refused_leave_requests = @employee.refused_leave_requests.find(:all, :limit => 5)
      
      @refused_by_me_leave_requests = LeaveRequest.find(:all, :conditions => ["(status = ? AND responsible_id = ?) OR (status = ? AND director_id = ?) AND start_date >= ?", LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE, @employee.id, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR, @employee.id, Date.today], :order => "start_date DESC" )        
      
      @leave_requests_to_treat = ( (@leave_requests_to_check.size > 0 and LeaveRequest.can_check?(current_user)) or
                                   (@leave_requests_to_notice.size > 0 and LeaveRequest.can_notice?(current_user)) or
                                   (@leave_requests_to_close.size > 0 and LeaveRequest.can_close?(current_user)) or
                                   @refused_by_me_leave_requests.size > 0 )
    end
  end
  
  # GET /leave_requests/:id
  def show
    @leave_request = LeaveRequest.find(params[:id])
  end
  
  # GET /leave_requests/new
  def new
    @leave_request = LeaveRequest.new
  end
  
  # GET /leave_requests/:id/edit
  def edit
    @leave_request = LeaveRequest.find(params[:id])
  end
  
  # POST /leave_requests
  def create
    @leave_request = LeaveRequest.new(params[:leave_request])
    @leave_request.employee = current_user.employee
    
    if @leave_request.submit
      flash[:notice] = 'La demande de congée a été créée avec succès et transférée à votre reponsable.'
      redirect_to(@leave_request)
    else
      render :action => "new"
    end    
  end
  
  # PUT /leave_requests/:id
  def update
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.update_attributes(params[:leave_request])
      flash[:notice] = "La réponse a été envoyée avec succès"
      redirect_to(leave_requests_url)
    else
      render :action => "edit"
    end     
  end
  
  # PUT /leave_requests/:id/check
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
  
  # PUT /leave_requests/:id/notice
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
  
  # PUT /leave_requests/:id/close
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
  
  # DELETE /leave_requests/:id
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
  
  # GET /accepted_leave_requests
  def accepted
    @employee = current_user.employee
    @accepted_leave_requests = @employee.accepted_leave_requests.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE)
  end
  
  # GET /refused_leave_requests
  def refused
    @employee = current_user.employee
    @refused_leave_requests = @employee.refused_leave_requests.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE)
  end
  
  # GET /cancelled_leave_requests
  def cancelled
    @employee = current_user.employee
    @cancelled_leave_requests = @employee.cancelled_leave_requests.paginate(:page => params[:page], :per_page => LeaveRequest::LEAVE_REQUESTS_PER_PAGE)
  end
  
end
