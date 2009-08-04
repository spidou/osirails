class RolePermissionsController < ApplicationController

  def index
    @roles = Role.find(:all)
  end
  
  def edit
    @role = Role.find(params[:id])
    @menu_permissions = @role.menu_permissions
    @business_object_permissions = @role.business_object_permissions
    @document_type_permissions = @role.document_type_permissions
    @calendar_permissions = @role.calendar_permissions
  end
 
  
  def update
    params[:business_object_permissions] ||= {}
    params[:menu] ||= {}
    params[:document] ||= {}
    params[:calendar] ||= {}
    
    error = false
    for permission in params[:business_object_permissions]
      unless BusinessObjectPermission.find(permission[0]).update_attributes(permission[1])
        error = true
        break
      end
    end
    
    transaction_error2 = MenuPermission.transaction do
      MenuPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
      MenuPermission.update_all("`list` = 1", :id => params[:menu][:list], :role_id =>params[:id])
      MenuPermission.update_all("`view` = 1",:id => params[:menu][:view], :role_id =>params[:id])
      MenuPermission.update_all("`add` = 1", :id => params[:menu][:add], :role_id =>params[:id])
      MenuPermission.update_all("`edit` = 1", :id => params[:menu][:edit], :role_id =>params[:id])
      MenuPermission.update_all("`delete` = 1", :id => params[:menu][:delete], :role_id =>params[:id])
    end
    
    transaction_error3 = DocumentTypePermission.transaction do
      DocumentTypePermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
      DocumentTypePermission.update_all("`list` = 1", :id => params[:document][:list], :role_id =>params[:id])
      DocumentTypePermission.update_all("`view` = 1", :id => params[:document][:view], :role_id =>params[:id])
      DocumentTypePermission.update_all("`add` = 1", :id => params[:document][:add], :role_id =>params[:id])
      DocumentTypePermission.update_all("`edit` = 1", :id => params[:document][:edit], :role_id =>params[:id])
      DocumentTypePermission.update_all("`delete` = 1", :id => params[:document][:delete], :role_id =>params[:id])
    end
    
    transaction_error4 = CalendarPermission.transaction do
      CalendarPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
      CalendarPermission.update_all("`list` = 1", :id => params[:calendar][:list], :role_id =>params[:id])
      CalendarPermission.update_all("`view` = 1", :id => params[:calendar][:view], :role_id =>params[:id])
      CalendarPermission.update_all("`add` = 1", :id => params[:calendar][:add], :role_id =>params[:id])
      CalendarPermission.update_all("`edit` = 1", :id => params[:calendar][:edit], :role_id =>params[:id])
      CalendarPermission.update_all("`delete` = 1", :id => params[:calendar][:delete], :role_id =>params[:id])
    end
    
    if !error and transaction_error2 and transaction_error3 and transaction_error4
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
    end
    
    redirect_to :action => "edit",:id => params[:id]
  end
  
end
