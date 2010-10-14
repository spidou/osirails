class PurchaseRequestsController < ApplicationController
  
  helper :purchase_request_supplies, :purchase_orders
  
  # GET /purchase_requests
  def index  
    @requests = PurchaseRequestSupply.sorted_by_priority_and_expected_delivery_date.collect(&:purchase_request).uniq.paginate(:page => params[:page], :per_page => PurchaseRequest::REQUESTS_PER_PAGE)
  end
  
  # GET /purchase_requests/:purchase_request_id
  def show
    @purchase_request = PurchaseRequest.find(params[:id])
  end
  
  # GET /purchase_requests/new
  def new
    @purchase_request = PurchaseRequest.new
    @purchase_request.user_id = current_user.id
  end
  
  # PUT /purchase_requests/
  def create
    @purchase_request = PurchaseRequest.new(params[:purchase_request])
    @purchase_request.user_id = current_user.id
    if @purchase_request.save
      flash[:notice] = "La demande d'achats a été créé(e) avec succès."
      redirect_to @purchase_request
    else
      render :action => "new"
    end
  end
  
  # GET /purchase_requests/:purchase_request_id/cancel_form
  def cancel_form  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    error_access_page(412) unless @purchase_request.can_be_cancelled?
  end
  
  # GET /purchase_requests/:purchase_request_id/cancel
  def cancel  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    if @purchase_request.can_be_cancelled?
      @purchase_request.canceller = current_user
      @purchase_request.cancelled_comment = params[:purchase_request][:cancelled_comment]
      if @purchase_request.cancel
        flash[:notice] = "La demande d'achat a été annulée avec succès."
        redirect_to @purchase_request
      else
        render :action => "cancel_form"
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_requests/:purchase_request_id/cancel_supply/:purchase_request_supply_id
  def cancel_supply  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    @purchase_request_supply = PurchaseRequestSupply.find(params[:purchase_request_supply_id])
    if @purchase_request_supply.can_be_cancelled?
      @purchase_request_supply.canceller = current_user
      flash[:notice] = "La fourniture a été annuléé avec succès." if @purchase_request_supply.cancel 
      redirect_to @purchase_request 
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_request_supply_in_one_line?supply_id=:supply_id
  def purchase_request_supply_in_one_line
    @supply = Supply.find(params[:supply_id])
    @purchase_request_supply = PurchaseRequestSupply.new(:supply_id => @supply.id)
    render :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line', :object => @purchase_request_supply
  end
end
