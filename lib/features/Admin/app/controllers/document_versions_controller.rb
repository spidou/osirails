class DocumentVersionsController < ApplicationController
  def preview_image
    @document_version = DocumentVersion.find(params[:id])
    @document = @document_version.document
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}/#{@document_version.id}.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
end
