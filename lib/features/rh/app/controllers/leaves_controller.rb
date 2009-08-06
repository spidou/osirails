class LeavesController < ApplicationController

  # GET /employees/ID/leaves
  # GET /employees/ID/leaves.xml
  def index
    @employee = Employee.find(params[:employee_id])
    @shift = (params[:leave_year_shift].nil?)? 0 : params[:leave_year_shift].to_i
    @leaves = @employee.get_leaves_for_choosen_year(@shift)
    @retrieval_leave = @employee.get_leaves_for_choosen_year(@shift+1).reject {|n| n.retrieval.nil? or n.retrieval == 0}
    
    respond_to do |format|
      format.js {render :action => "index", :layout => false}
      format.html {render :action => "index"}
    end
  end
  
  def destroy
    @leave = Leave.find(params[:id])
    unless @leave.cancel
      flash[:notice] = "Impossible de supprimer le congé"
    end
    redirect_to employee_leaves_path
  end
  
end
