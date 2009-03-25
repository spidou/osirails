class DocumentsController < ApplicationController
  
  # GET /:document_owner/:document_owner_id/documents
  # 
  # ==== Examples
  #   GET /customers/1/documents
  #   GET /employees/1/documents
  #
  def index
    hash = params.select{ |key, value| key.end_with?("_id") }
    raise "An error has occured. The DocumentsController should receive at least 1 param which ends with '_id'" if hash.size < 1
    raise "An error has occured. The DocumentsController shouldn't receive more than 1 params which ends with '_id'" if hash.size > 1
    
    owner_class = hash.first.first.chomp("_id").camelize.constantize
    owner_id = hash.first.last
    @documents_owner = owner_class.send(:find, owner_id)

    @group_by = params[:group_by] || "date"
    @order_by = params[:order_by] || "asc" # ascendent

    render :layout => false
  end

end
