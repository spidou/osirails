class SubcontractorRequestsController < ApplicationController
  
  # GET /subcontractor_requests/:id/quote
  def quote
    @subcontractor_request = SubcontractorRequest.find(params[:id])
    if @subcontractor_request.attachment
      send_data File.read(@subcontractor_request.attachment.path), :filename => "#{@subcontractor_request.attachment_file_name}", :type => @subcontractor_request.attachment_content_type, :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
end
