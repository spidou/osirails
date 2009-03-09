class BusinessObjectPermissionsController < ApplicationController
  
  # GET /business_object_permissions
  def index
    @business_objects = BusinessObject.find(:all)
  end
  
  # GET /business_object_permissions/:id/edit
  # :id corresponds to a business_object id
  def edit
    @business_object = BusinessObject.find(params[:id])
    @business_object_permissions = @business_object.permissions
  end
  
  # POST /business_object_permissions/:id
  # :id corresponds to a business_object id
  def update
    transaction_error = BusinessObjectPermission.transaction do
      BusinessObjectPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :business_object_id => params[:id])
      BusinessObjectPermission.update_all("`list` = 1", :role_id => params[:list], :business_object_id => params[:id])
      BusinessObjectPermission.update_all("`view` = 1", :role_id => params[:view], :business_object_id => params[:id])
      BusinessObjectPermission.update_all("`add` = 1", :role_id => params[:add], :business_object_id => params[:id])
      BusinessObjectPermission.update_all("`edit` = 1", :role_id => params[:edit], :business_object_id => params[:id])
      BusinessObjectPermission.update_all("`delete` = 1", :role_id => params[:delete], :business_object_id => params[:id])
    end
    if transaction_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"      
    end
    redirect_to(edit_business_object_permission_path)
  end
end
