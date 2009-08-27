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
    @permission_methods = @document_type_permissions.first.permission_methods
  end
  
  # POST /document_type_permissions/:id
  # :id corresponds to a document_type id
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
    redirect_to(edit_document_type_permission_path)
  end
end
