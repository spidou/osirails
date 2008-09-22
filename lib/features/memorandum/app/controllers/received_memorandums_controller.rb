class ReceivedMemorandumsController < ApplicationController

  # GET /received_memorandums
  def index
    received_memorandums = Memorandum.find_by_services(current_user.employee.services)
    @received_memorandums = received_memorandums.paginate :page => params[:memorandum],:per_page => 10
  end
  
  # GET /received_memorandums
  def show
    @received_memorandum = Memorandum.find(params[:id])
  end
  
end