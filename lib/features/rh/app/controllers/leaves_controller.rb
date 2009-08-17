class LeavesController < ApplicationController

  # GET /employees/:employee_id/leaves
  def index
    @employee        = Employee.find(params[:employee_id])
    @year            = (params[:leave_year].nil?)? Employee.leave_year_start_date.year : params[:leave_year].to_i
    @view_cancelled  = params[:cancelled] || false  # if true permit to see cancelled leaves
    @leaves          = @employee.get_leaves_for_choosen_year(@year, @view_cancelled)
    
#    @retrieval_leave = @employee.get_leaves_for_choosen_year(@shift+1).reject {|n| n.retrieval.nil? or n.retrieval == 0}
    
    respond_to do |format|
      format.js   {render :action => "index", :layout => false}
      format.html {render :action => "index"}
    end
  end
  
  # GET /employees/:employee_id/leaves/:id/cancel
  def cancel
    @leave = Leave.find(params[:id])
    @leave.cancel
    redirect_to employee_leaves_path
  end
  
  # DELETE /employees/:employee_id/leaves/:id
  def destroy
    @leave = Leave.find(params[:id])
    @leave.destroy
    redirect_to employee_leaves_path
  end
  
end
