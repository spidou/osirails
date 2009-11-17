class CalendarPermissionsController < ApplicationController
  def index
    @calendars = Calendar.find_all_by_user_id(nil)
  end

  def edit
    @calendar = Calendar.find(params[:id])
    @calendar_permissions = @calendar.permissions
    @permission_methods = @calendar_permissions.first.permission_methods
  end

  def update
    error = false
    for permission in params[:permissions]
      error = true unless Permission.find(permission[0]).update_attributes(permission[1])
    end
    
    if error
      flash[:error] = "Erreur lors de la mise à jour des permissions"
    else
      flash[:notice] = "Les permissions ont été modifié avec succès"
    end
    redirect_to(edit_calendar_permission_path)
  end
end
