class AttachmentsController < ApplicationController
  
  # GET /attachments/:id/:style
  # actually, :id corresponds to a document id
  # and this controller permits to display the attachment of a document
  # 
  # ==== Examples
  #   GET /attachments/1/thumb
  #   GET /attachments/1/medium
  #   GET /attachments/1 # => original by default
  #
  def show
    @document = Document.find(params[:id])
    disposition = params[:download].nil? ? 'inline' : 'attachment'
    
    if @document.can_view?(current_user)
      url = @document.attachment.path(params[:style])
      
      send_data File.read(url), :filename => "#{@document.id}_#{@document.attachment_file_name}", :type => @document.attachment_content_type, :disposition => disposition
    else
      send_data File.read(Document.forbidden_document_image_path), :filename => "forbidden.png", :type => "image/png", :disposition => disposition
    end
  end
  
end
