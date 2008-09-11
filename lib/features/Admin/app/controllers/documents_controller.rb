class DocumentsController < ApplicationController
  
  def show
    @document = Document.find(params[:id])
    
    @document_versions = @document.document_versions
    @document_version = DocumentVersion.new()
  end
  
  def edit
    @document = Document.find(params[:id])
    @document_last_version =@document.document_versions.last
  end
  
  def update
    @document = Document.find(params[:id])
    params[:document][:upload] = params[:upload]
#    @document.update(params[:document])
#    params[:document].delete("tag_list")
#    params[:document].delete("upload")
    @document.update_attributes(params[:document])
  end
  
  ## This method return the image to show
  def preview_image
    @document = Document.find(params[:id])
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
  def thumbnail 
    @document = Document.find(params[:id])
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}_75_75.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
end
