class DocumentsController < ApplicationController
  
  # GET /:document_owner/:document_owner_id/documents
  # 
  # ==== Examples
  #   GET /customers/1/documents
  #   GET /employees/1/documents
  #
  def index
    raise "An error has occured, params[:owner] is expected" unless params[:owner]
    raise "An error has occured, params[:owner_id] is expected" unless params[:owner_id]
    
    begin
      owner_class = params[:owner].constantize
      @documents_owner = owner_class.send(:find, params[:owner_id])
      @group_by = params[:group_by] || "date"
      @order_by = params[:order_by] || "asc" # ascendent
    rescue Exception => e
      if Rails.env.production?
        logger.error("[#{DateTime.now}] (#{File.basename(__FILE__)}) > #{e.message}")
        flash.now[:error] = "Une erreur est critique est survenue. Merci de signaler le problème à votre administrateur."
      else
        raise e
      end
    end
    
    render :layout => false
  end
  
end
