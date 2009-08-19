class MenuPermissionsController < ApplicationController
  
  # GET /menu_permissions
  def index
    @menus = Menu.get_structured_menus
  end
  
  # GET /menu_permissions/:id/edit
  # :id corresponds to a menu id
  def edit
    @menu = Menu.find(params[:id])
    @menu_permissions = @menu.permissions
    @permission_methods = @menu_permissions.first.permission_methods
  end
  
  # POST /menu_permissions/:id
  # :id corresponds to a menu id
  def update
    error = false
    for permission in params[:permissions]
      error = true unless Permission.find(permission[0]).update_attributes(permission[1])
    end
    
    if error
      flash[:error] = "Erreur lors de la mise à jour des permissions"
    else
      flash[:notice] = "Les permissions ont été modifié avec succés"
    end
    redirect_to(edit_menu_permission_path)
  end
end
