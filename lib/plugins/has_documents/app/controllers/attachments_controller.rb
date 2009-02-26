class AttachmentsController < ApplicationController
  
  # GET /attachments/:id/:style
  # 
  # ==== Example
  #   GET /attachments/1/thumb
  #   GET /attachments/1 # => original by default
  #
  def show
    @document = Document.find(params[:id])
    
    disposition = params[:download].nil? ? 'inline' : 'attachment'
    ext = File.extname(@document.attachment.path)
    dir = File.dirname(@document.attachment.path)
    url = "#{dir}/#{params[:style]||"original"}#{ext}"
    url = File.exists?(url) ? url : @document.attachment
    
    send_data File.read(url), :filename => @document.attachment_file_name, :type => @document.attachment_content_type, :disposition => disposition
  end
  
end