class DocumentTypePermissionsController < ApplicationController

  # GET /document_type_permissions
  def index
    @document_types = DocumentType.find(:all)
  end
  
  # GET /document_type_permissions/:id/edit
  # :id corresponds to a document_type id
  def edit
    @document_type = DocumentType.find(params[:id])
    @document_type_permissions = @document_type.permissions
  end
  
  # POST /document_type_permissions/:id
  # :id corresponds to a document_type id
  def update
    transaction_error = DocumentTypePermission.transaction do
      DocumentTypePermission.update_all("`list` = 0, `view` = 0, `add` = 0, `edit` = 0, `delete` = 0", :document_type_id => params[:id])
      DocumentTypePermission.update_all("`list` = 1", :role_id => params[:list], :document_type_id => params[:id])
      DocumentTypePermission.update_all("`view` = 1", :role_id => params[:view], :document_type_id => params[:id])
      DocumentTypePermission.update_all("`add` = 1", :role_id => params[:add], :document_type_id => params[:id])
      DocumentTypePermission.update_all("`edit` = 1", :role_id => params[:edit], :document_type_id => params[:id])
      DocumentTypePermission.update_all("`delete` = 1", :role_id => params[:delete], :document_type_id => params[:id])
    end
    if transaction_error
      flash[:notice] = "Les permissions ont été modifié avec succés"
    else
      flash[:error] = "Erreur lors de la mise à jour des permissions"      
    end
    redirect_to(edit_document_type_permission_path)
  end
end
