class AdjustmentAttachmentsController < ApplicationController
  
  # GET /adjustment_attachments/:id
  def show
    @adjustment = Adjustment.find(params[:id])
    url = @adjustment.attachment.path
    
    send_data File.read(url), :filename => "ajustement.#{@adjustment.id}_#{@adjustment.attachment_file_name}", :type => @adjustment.attachment_content_type, :disposition => 'attachment'
  end
end
