class LeaveRequestsController < ApplicationController
  helper :employees
  # GET /leave_requests
  def index
    
    @employee = current_user.employee
    
    if @employee
      @in_progress_leave_requests = @employee.in_progress_leave_requests
      @accepted_leave_requests    = @employee.accepted_leave_requests.find(:all, :limit => 5)
      @refused_leave_requests     = @employee.refused_leave_requests.find(:all, :limit => 5)
      
      @pending_leave_requests = []
      @pending_leave_requests += @employee.get_leave_requests_to_check  if LeaveRequest.can_check?(current_user)
      @pending_leave_requests += LeaveRequest.leave_requests_to_notice  if LeaveRequest.can_notice?(current_user)
      @pending_leave_requests += LeaveRequest.leave_requests_to_close   if LeaveRequest.can_close?(current_user)
      @pending_leave_requests += @employee.get_leave_requests_refused_by_myself
      @pending_leave_requests = @pending_leave_requests.sort_by(&:start_date).reverse
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
  
  # GET /leave_requests/:id/check_form
  def check_form
    @leave_request = LeaveRequest.find(params[:id])
    error_access_page(403) unless @leave_request.can_be_checked?
  end
  
  # GET /leave_requests/:id/notice_form
  def notice_form
    @leave_request = LeaveRequest.find(params[:id])
    error_access_page(403) unless @leave_request.can_be_noticed?
  end
  
  # GET /leave_requests/:id/close_form
  def close_form
    @leave_request = LeaveRequest.find(params[:id])
    error_access_page(403) unless @leave_request.can_be_closed?
  end
  
  # POST /leave_requests
  def create
    @leave_request = LeaveRequest.new(params[:leave_request])
    @leave_request.employee = current_user.employee
    
    if @leave_request.submit
      flash[:notice] = "Votre demande de congés a été créée avec succès et transférée à votre reponsable"
      redirect_to(@leave_request)
    else
      render :action => "new"
    end    
  end
  
  # PUT /leave_requests/:id/check
  def check
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.can_be_checked?
      @leave_request.attributes = params[:leave_request]
      @leave_request.responsible = current_user.employee
      if @leave_request.check
        flash[:notice] = "La demande de congés a été traitée avec succès"
        redirect_to(leave_requests_url)
      else
        render :action => :check_form
      end
    else
      error_access_page(403)
    end
  end
  
  # PUT /leave_requests/:id/notice
  def notice
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.can_be_noticed?
      @leave_request.attributes = params[:leave_request]
      @leave_request.observer = current_user.employee
      if @leave_request.notice
        flash[:notice] = "La demande de congés a été traitée avec succès"
        redirect_to(leave_requests_url)
      else
        render :action => :notice_form
      end
    else
      error_access_page(403)
    end
  end
  
  # PUT /leave_requests/:id/close
  def close
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.can_be_closed?
      @leave_request.attributes = params[:leave_request]
      @leave_request.director = current_user.employee
      if @leave_request.close 
        flash[:notice] = "La demande de congés a été traitée avec succès"
        flash[:notice] << " et le congé a été créé" if @leave_request.was_closed?
        redirect_to(leave_requests_url)
      else
        render :action => :close_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /leave_requests/:id/cancel
  def cancel
    @leave_request = LeaveRequest.find(params[:id])
    
    if @leave_request.can_be_cancelled?
      @employee = current_user.employee
      @leave_request.cancelled_by = @employee.id
      unless @leave_request.cancel
        flash[:error] = "Une erreur est survenue à l'annulation de la demande de congés"
      end
      redirect_to(leave_requests_url)
    else
      error_access_page(403)
    end
  end
  
  # DELETE /leave_requests/:id
  def destroy
    @leave_request = LeaveRequest.find(params[:id])
    unless @leave_request.destroy
      flash[:error] = "Une erreur est survenue à la suppression de la demande de congés"
    end
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
