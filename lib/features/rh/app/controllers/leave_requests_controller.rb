class LeaveRequestsController < ApplicationController

  # GET /leave_requests
  # GET /leave_requests.xml
  def index
    if !current_user.employee.nil?
      @employee = true
      @active_leave_requests = LeaveRequest.find(:all, :conditions => { :status => [LeaveRequest::STATUS_SUBMITTED,LeaveRequest::STATUS_CHECKED,LeaveRequest::STATUS_NOTICED], :employee_id => current_user.employee.id }, :order => "start_date, created_at DESC" )
      @accepted_leave_requests = LeaveRequest.find(:all, :conditions => { :status => LeaveRequest::STATUS_CLOSED, :employee_id => current_user.employee.id }, :order => "start_date, created_at DESC", :limit => 5 )
      @refused_leave_requests = LeaveRequest.find(:all, :conditions => { :status => [LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE,LeaveRequest::STATUS_REFUSED_BY_DIRECTOR], :employee_id => current_user.employee.id }, :order => "start_date, created_at DESC", :limit => 5 )
      @leave_requests_to_check = LeaveRequest.find(:all, :conditions => { :status => LeaveRequest::STATUS_SUBMITTED }, :order => "start_date, created_at DESC" )
      @leave_requests_to_notice = LeaveRequest.find(:all, :conditions => { :status => LeaveRequest::STATUS_CHECKED }, :order => "start_date, created_at DESC" )
      @leave_requests_to_close = LeaveRequest.find(:all, :conditions => { :status => LeaveRequest::STATUS_NOTICED }, :order => "start_date, created_at DESC" )
    else
      @employee = false
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_requests }
    end
  end

  # GET /leave_requests/1
  # GET /leave_requests/1.xml
  def show
    @leave_request = LeaveRequest.find(params[:id])
    
    @employee = @leave_request.employee
    
    @start_date = @leave_request.start_date
    @end_date = @leave_request.end_date
    
    case @leave_request.leave_type_id
      when 1
        @leave_type = "Congés payés"
      when 2
        @leave_type = "Congés de formation"
      when 3
        @leave_type = "Congé paternité"
      when 4 
        @leave_type = "Congé d'examen"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @leave_request }
    end
  end

  # GET /leave_requests/new
  # GET /leave_requests/new.xml
  def new
    @employee = current_user.employee
    @employee_id = current_user.employee.id
    @leave_request = LeaveRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @leave_request }
    end
  end

  # GET /leave_requests/1/edit
  def edit
    @leave_request = LeaveRequest.find(params[:id])
    
    case @leave_request.leave_type_id
      when 1
        @leave_type = "Congés payés"
      when 2
        @leave_type = "Congés de formation"
      when 3
        @leave_type = "Congé paternité"
      when 4 
        @leave_type = "Congé d'examen"
    end
    
  end

  # POST /leave_requests
  # POST /leave_requests.xml
  def create
    @leave_request = LeaveRequest.new(params[:leave_request])    

    respond_to do |format|
      if @leave_request.submit
        flash[:notice] = 'La demande de congée a été créée avec succès et transférée à votre reponsable.'
        format.html { redirect_to(@leave_request) }
        format.xml  { render :xml => @leave_request, :status => :created, :location => @leave_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @leave_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leave_requests/1
  # PUT /leave_requests/1.xml
  def update
    @leave_request = LeaveRequest.find(params[:id])

    respond_to do |format|
      if @leave_request.update_attributes(params[:leave_request])
        flash[:notice] = "La réponse a été envoyée avec succès"
        format.html { redirect_to(leave_requests_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @leave_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leave_requests/1
  # DELETE /leave_requests/1.xml
  def destroy
    @leave_request = LeaveRequest.find(params[:id])
    @leave_request.destroy

    respond_to do |format|
      format.html { redirect_to(leave_requests_url) }
      format.xml  { head :ok }
    end
  end
  
  def accepted
    @accepted_leave_requests = LeaveRequest.find(:all, :conditions => { :status => LeaveRequest::STATUS_CLOSED, :employee_id => current_user.employee.id }, :order => "start_date, created_at DESC" )
  end
  
  def refused
    @refused_leave_requests = LeaveRequest.find(:all, :conditions => { :status => [LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE,LeaveRequest::STATUS_REFUSED_BY_DIRECTOR], :employee_id => current_user.employee.id }, :order => "start_date, created_at DESC" )
  end
  
end
