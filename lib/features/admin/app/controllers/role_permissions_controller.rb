class RolePermissionsController < ApplicationController
  helper :menus
  def index
    @roles = Role.find(:all)
  end
  
  def edit
    @role = Role.find(params[:id])
    @permissions = @role.permissions.group_by(&:has_permissions_type)
  end
  
  def update
    error = false
    for permission in params[:permissions]
      unless Permission.find(permission[0]).update_attributes(permission[1])
        error = true
        break
      end
    end
    
    unless error
      flash[:notice] = "Les permissions ont été modifié avec succès"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
    end
    
    redirect_to :action => "edit", :id => params[:id]
  end
  
end
