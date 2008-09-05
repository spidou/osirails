class DocumentVersionsController < ApplicationController
  def preview_image
    puts params[:last]
    unless params[:last] == 'true'
      @document_version = DocumentVersion.find(params[:id])
      @document = @document_version.document    
      path = "documents/#{@document.owner_class}/#{@document.file_type_id}/#{@document.id}/#{@document_version.version}.jpg"
    else
      @document = Document.find(params[:id])
      path = "documents/#{@document.path}/#{@document.id}/#{@document.document_versions.size}.jpg"
    end
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
    
  end
  
  def thumbnail 
    unless params[:last] == 'true'
      @document_version = DocumentVersion.find(params[:id])
      path = "documents/#{@document_version.path}/#{@document_version.version}_75_75.jpg"
    else
      @document = Document.find(params[:id])
      path = "documents/#{@document.path}/#{@document.id}/#{@document.document_versions.size}_75_75.jpg"
    end
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
end
