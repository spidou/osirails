class RolePermissionsController < ApplicationController
  
  def index
    @roles = Role.find(:all)
  end
  
  def edit
    @role = Role.find(params[:id])
    @menu_permissions = MenuPermission.find(:all, :include => [:menu], :conditions => ["role_id=?",params[:id]])
    
    @business_object_permissions = BusinessObjectPermission.find(:all, :conditions => ["role_id=?",params[:id]])

  end
 
  
  def update
    params[:business_object] ||= {}
    params[:menu]||={}
      transaction_error = BusinessObjectPermission.transaction do
        BusinessObjectPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
        BusinessObjectPermission.update_all("`list` = 1", :id => params[:business_object][:list], :role_id =>params[:id])
        BusinessObjectPermission.update_all("`view` = 1", :id => params[:business_object][:view], :role_id =>params[:id])
        BusinessObjectPermission.update_all("`add` = 1", :id => params[:business_object][:add], :role_id =>params[:id])
        BusinessObjectPermission.update_all("`edit` = 1", :id => params[:business_object][:edit], :role_id =>params[:id])
        BusinessObjectPermission.update_all("`delete` = 1", :id => params[:business_object][:delete], :role_id =>params[:id])
      end
      transaction_error2 = MenuPermission.transaction do
        MenuPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
        MenuPermission.update_all("`list` = 1", :id => params[:menu][:list], :role_id =>params[:id])
        MenuPermission.update_all("`view` = 1",:id => params[:menu][:view], :role_id =>params[:id])
        MenuPermission.update_all("`add` = 1", :id => params[:menu][:add], :role_id =>params[:id])
        MenuPermission.update_all("`edit` = 1", :id => params[:menu][:edit], :role_id =>params[:id])
        MenuPermission.update_all("`delete` = 1", :id => params[:menu][:delete], :role_id =>params[:id])
      end
    
    if transaction_error or transaction_error2
      flash[:notice] = "Les permissions ont été modifié avec succés"
      redirect_to :action => "edit",:id => params[:id]
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
      redirect_to :action => "edit",:id => params[:id]
    end
  end
  
end
