class BusinessObjectPermissionsController < ApplicationController
  
  # GET /business_object_permissions
  def index
    @business_objects = BusinessObject.all
  end
  
  # GET /business_object_permissions/:id/edit
  # :id corresponds to a business_object id
  def edit
    @business_object = BusinessObject.find(params[:id])
    @business_object_permissions = @business_object.permissions
    @permission_methods = @business_object_permissions.first.permission_methods
  end
  
  # POST /business_object_permissions/:id
  # :id corresponds to a business_object id
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
    
    redirect_to(edit_business_object_permission_path)
  end
end
