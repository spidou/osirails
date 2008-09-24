class ReceivedMemorandumsController < ApplicationController

  # GET /received_memorandums
  def index
    unless current_user.employee.nil?
      received_memorandums = Memorandum.find_by_services(current_user.employee.services)
      @received_memorandums = received_memorandums.paginate :page => params[:memorandum],:per_page => 10
    else
      flash.now[:error] = "Vous ne pouvez pas recevoir de notes de service si vous n'etes pas associ&eacute;s &agrave; un service"
    end
  end
  
  # GET /received_memorandums
  def show
    @received_memorandum = Memorandum.find(params[:id])
  end
  
end
