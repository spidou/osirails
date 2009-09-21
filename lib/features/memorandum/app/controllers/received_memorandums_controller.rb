class ReceivedMemorandumsController < ApplicationController

  # GET /received_memorandums
  def index
    unless current_user.employee
      flash.now[:error] = "Vous ne pouvez pas recevoir de notes de service si vous n'êtes pas associés à un employé"
    else
      @received_memorandums = Memorandum.find_by_services([current_user.employee.service]).paginate(:page => params[:memorandum],:per_page => 10)
    end
  end
  
  # GET /received_memorandums
  def show
    @received_memorandum = Memorandum.find(params[:id])
  end
  
end
