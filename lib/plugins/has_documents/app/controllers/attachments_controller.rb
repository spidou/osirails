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
    
    if ( disposition == 'inline' and @document.can_view?(current_user) ) or ( disposition == 'attachment' and @document.can_download?(current_user))
      url = @document.attachment.path(params[:style])
      
      unless File.exists?(url)
        url = Document.missing_document_image_path
        disposition = 'inline'
      end
      
      send_data File.read(url), :filename => "#{@document.id}_#{@document.attachment_file_name}", :type => @document.attachment_content_type, :disposition => disposition
    else
      if disposition == 'inline'
        send_data File.read(Document.forbidden_document_image_path), :filename => "forbidden.png", :type => "image/png", :disposition => 'inline'
      else
        error_access_page(403)
      end
    end
  end
  
end
