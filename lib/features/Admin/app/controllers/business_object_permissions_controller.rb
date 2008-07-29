class BusinessObjectPermissionsController < ApplicationController
  def index
    @business_object_permissions = BusinessObjectPermission.find(:all, :group => 'has_permission_type')
  end

  def edit
    @business_object_permissions = BusinessObjectPermission.find(:all, :conditions => ["has_permission_type = ?", params[:name]], :include => [:role] )
    @roles = Role.find(:all)
  end

  def update
    @business_object_permissions = BusinessObjectPermission.find(:all, :conditions => ["has_permission_type = ?", params[:name]] )
    save_error = false
    @business_object_permissions.each do |business_object_permission|
      params[:list] ||= []
      business_object_permission.list = params[:list].include?(business_object_permission.role_id.to_s)
      params[:view] ||= []
      business_object_permission.view = params[:view].include?(business_object_permission.role_id.to_s)
      params[:add] ||= []
      business_object_permission.add = params[:add].include?(business_object_permission.role_id.to_s)
      params[:edit] ||= []
      business_object_permission.edit = params[:edit].include?(business_object_permission.role_id.to_s)
      params[:delete] ||= []
      business_object_permission.delete = params[:delete].include?(business_object_permission.role_id.to_s)
      save_error ||= !business_object_permission.save
    end

    unless save_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
      redirect_to(:action => 'edit', :name => params[:name]) 
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"
      render :action => "edit" 
    end
  end

end
