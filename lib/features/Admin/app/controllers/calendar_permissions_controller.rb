class CalendarPermissionsController < ApplicationController
  def index
    @calendar_permissions = Calendar.find_all_by_user_id(nil)
  end

  def edit
    @calendar = Calendar.find(params[:id])
    @calendar_permissions = CalendarPermission.find(:all, :conditions => ["calendar_id = ?", params[:id]], :include => [:role])
  end

  def update
    transaction_error = CalendarPermission.transaction do
      CalendarPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :calendar_id => params[:id])
      CalendarPermission.update_all("`list` = 1", :role_id => params[:list], :calendar_id => params[:id])
      CalendarPermission.update_all("`view` = 1", :role_id => params[:view], :calendar_id => params[:id])
      CalendarPermission.update_all("`add` = 1", :role_id => params[:add], :calendar_id => params[:id])
      CalendarPermission.update_all("`edit` = 1", :role_id => params[:edit], :calendar_id => params[:id])
      CalendarPermission.update_all("`delete` = 1", :role_id => params[:delete], :calendar_id => params[:id])
    end
    if transaction_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"      
    end
    redirect_to(edit_calendar_permission_path)
  end
end