class AttachmentsController < ApplicationController
  
  # GET /attachments/1/small.png
  def show
    @document = Document.find(params[:id])
    
    ext = File.extname(@document.attachment.path)
    dir = File.dirname(@document.attachment.path)
    url = "#{dir}/#{params[:style]}#{ext}"
    send_data File.read(url), :filename => @document.attachment_file_name, :type => @document.attachment_content_type, :disposition => 'inline'
  end
  
end