class PaymentAttachmentsController < ApplicationController
  
  # GET /payment_attachments/:id
  def show
    @payment = Payment.find(params[:id])
    url = @payment.attachment.path
    
    send_data File.read(url), :filename => "reglement.#{@payment.id}_#{@payment.attachment_file_name}", :type => @payment.attachment_content_type, :disposition => 'attachment'
  end
end
