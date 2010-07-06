class PurchaseRequestsController < ApplicationController
  
  helper :purchase_request_supplies, :purchase_orders
  
  def index  
    conditions = "1" if (params[:filter]) == 'all'
    conditions = "cancelled_by IS NULL" if (params[:filter]) == nil or (params[:filter]) == 'in_progress'
    conditions = "cancelled_by IS NOT NULL"  if (params[:filter]) == 'cancelled' 
    @requests = PurchaseRequest.all(:conditions => conditions, :order => "created_at DESC").paginate(:page => params[:page], :per_page => PurchaseRequest::REQUESTS_PER_PAGE)
  end
  
  def show
    @purchase_request = PurchaseRequest.find(params[:id])
  end
  
  def new
    @purchase_request = PurchaseRequest.new
    @purchase_request.user_id = current_user.id
  end
  
  def create
    @purchase_request = PurchaseRequest.new(params[:purchase_request])
    @purchase_request.user_id = current_user.id
    if @purchase_request.save
      flash[:notice] = "La demande d'achat a été créé(e) avec succès."
      redirect_to @purchase_request
    else
      render :action => "new"
    end
  end
  
  def cancel_form  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    error_access_page(412) unless @purchase_request.can_be_cancelled?
  end
  
  def cancel  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    if @purchase_request.can_be_cancelled?
      @purchase_request.cancelled_by = current_user.id
      @purchase_request.cancelled_comment  = params[:purchase_request][:cancelled_comment]
      if  @purchase_request.cancel
        flash[:notice] = "La demande d'achat a été annuléé avec succès."
        redirect_to @purchase_request
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def cancel_supply  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    @purchase_request_supply = PurchaseRequestSupply.find(params[:purchase_request_supply_id])
    if @purchase_request_supply.can_be_cancelled?
      @purchase_request_supply.cancelled_by = current_user.id
      flash[:notice] = "La fourniture a été annuléé avec succès." if @purchase_request_supply.cancel 
      redirect_to @purchase_request 
    else
      error_access_page(412)
    end
  end
  
  def get_request_supply
    @supply = Supply.find(params[:supply_id])
    @purchase_request_supply = PurchaseRequestSupply.new
    @purchase_request_supply.supply_id = params[:supply_id]
    render :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line',
                                                 :object  => @purchase_request_supply
  end
end
