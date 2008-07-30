class RolePermissionsController < ApplicationController
  
  def index
    @roles = Role.find(:all)
  end
  
  def edit
    @role = Role.find(params[:id])
    
    redirect_to role_permissions_path
  end
  
  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role_permission])
      flash[:notice] = 'Les permissions pour ce r&ocirc;le ont &eacute;t&eacute; mis-&agrave;-jour avec succ&egrave;s.'
      redirect_to(@roles)
    else
      render :action => "edit" 
    end
  end
end
