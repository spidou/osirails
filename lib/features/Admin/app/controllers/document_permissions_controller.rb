class DocumentPermissionsController < ApplicationController
  def index
    @document_permissions = Document.models
  end

  def edit
    @document_permissions = DocumentPermission.find(:all, :conditions => ["document_owner = ?", params[:id]], :include => [:role] )
  end

  def update
    transaction_error = DocumentPermission.transaction do
      DocumentPermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :document_owner => params[:id])
      DocumentPermission.update_all("`list` = 1", :role_id => params[:list], :document_owner => params[:id])
      DocumentPermission.update_all("`view` = 1", :role_id => params[:view], :document_owner => params[:id])
      DocumentPermission.update_all("`add` = 1", :role_id => params[:add], :document_owner => params[:id])
      DocumentPermission.update_all("`edit` = 1", :role_id => params[:edit], :document_owner => params[:id])
      DocumentPermission.update_all("`delete` = 1", :role_id => params[:delete], :document_owner => params[:id])
    end
    if transaction_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"      
    end
    redirect_to(edit_document_permission_path)
  end
end