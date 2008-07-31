class MenuPermissionsController < ApplicationController
  def index
    @menu_permissions = Menu.get_structured_menus("☞ ")
  end

  def edit
    @menu_permissions = MenuPermission.find(:all, :conditions => ["menu_id = ?", params[:id]], :include => [:menu])
  end

  def update
    transaction_error = MenuPermission.transaction do
      MenuPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :menu_id => params[:id])
      MenuPermission.update_all("`list` = 1", :role_id => params[:list], :menu_id => params[:id])
      MenuPermission.update_all("`view` = 1", :role_id => params[:view], :menu_id => params[:id])
      MenuPermission.update_all("`add` = 1", :role_id => params[:add], :menu_id => params[:id])
      MenuPermission.update_all("`edit` = 1", :role_id => params[:edit], :menu_id => params[:id])
      MenuPermission.update_all("`delete` = 1", :role_id => params[:delete], :menu_id => params[:id])
    end
    if transaction_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
    end
    redirect_to(edit_menu_permission_path)
  end
end