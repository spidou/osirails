class ContactsController < ApplicationController
  
  # GET /:contact_owner/:contact_owner_id/contacts
  # 
  # ==== Examples
  #   GET /customers/1/contacts
  #   GET /supplier/3/contacts
  #
  def index
    hash = params.select{ |key, value| key.end_with?("_id") }
    raise "An error has occured. The ContactsController should receive at least 1 param which ends with '_id'" if hash.size < 1
    raise "An error has occured. The ContactsController shouldn't receive more than 1 params which ends with '_id'" if hash.size > 1
    
    owner_class = hash.first.first.chomp("_id").camelize.constantize
    owner_id = hash.first.last
    @contacts_owner = owner_class.send(:find, owner_id)

    @group_by = params[:group_by] || "type"
    @order_by = params[:order_by] || "asc" # ascendent

    render :layout => false
  end

end
