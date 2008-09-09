class RolePermissionsController < ApplicationController

  def index
    @roles = Role.find(:all)
  end
  
  def edit
    @role = Role.find(params[:id])
    @menu_permissions = MenuPermission.find(:all, :include => [:menu], :conditions => ["role_id = ?", params[:id]])
    
    @business_object_permissions = BusinessObjectPermission.find(:all, :conditions => ["role_id = ?", params[:id]])
    @document_permissions = DocumentPermission.find(:all, :group => 'document_owner', :conditions => ["role_id = ?", params[:id]])
    @all_calendar = Calendar.find_all_by_user_id(nil)
    @calendar_permissions = CalendarPermission.find(:all, :conditions => ["role_id = ? and calendar_id IN (?)", params[:id], @all_calendar])
  end
 
  
  def update
    params[:business_object] ||= {}
    params[:menu] ||= {}
    params[:document] ||= {}
    params[:calendar] ||= {}
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
      
      transaction_error3 = DocumentPermission.transaction do
        DocumentPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
        DocumentPermission.update_all("`list` = 1", :id => params[:document][:list], :role_id =>params[:id])
        DocumentPermission.update_all("`view` = 1", :id => params[:document][:view], :role_id =>params[:id])
        DocumentPermission.update_all("`add` = 1", :id => params[:document][:add], :role_id =>params[:id])
        DocumentPermission.update_all("`edit` = 1", :id => params[:document][:edit], :role_id =>params[:id])
        DocumentPermission.update_all("`delete` = 1", :id => params[:document][:delete], :role_id =>params[:id])
      end
      
      transaction_error4 = CalendarPermission.transaction do
        CalendarPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :role_id =>params[:id])
        CalendarPermission.update_all("`list` = 1", :id => params[:calendar][:list], :role_id =>params[:id])
        CalendarPermission.update_all("`view` = 1", :id => params[:calendar][:view], :role_id =>params[:id])
        CalendarPermission.update_all("`add` = 1", :id => params[:calendar][:add], :role_id =>params[:id])
        CalendarPermission.update_all("`edit` = 1", :id => params[:calendar][:edit], :role_id =>params[:id])
        CalendarPermission.update_all("`delete` = 1", :id => params[:calendar][:delete], :role_id =>params[:id])
      end
    
    if transaction_error or transaction_error2 or transaction_error3 or transaction_error4
      flash[:notice] = "Les permissions ont été modifié avec succés"
      redirect_to :action => "edit",:id => params[:id]
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
      redirect_to :action => "edit",:id => params[:id]
    end
  end
  
end
