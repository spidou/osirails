class PurchaseRequestsController < ApplicationController
  
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
  end

  def cancel_supply  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    @purchase_request_supply = PurchaseRequestSupply.find(params[:purchase_request_supply_id])
    
    @purchase_request_supply.cancelled_by = current_user.id
    if @purchase_request_supply.cancel
      flash[:notice] = "La fourniture a été annuléé avec succès."  
    end 
    redirect_to @purchase_request 
  end
  
  def cancel  
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id])
    @purchase_request.cancelled_by = current_user.id
    @purchase_request.cancelled_comment  = params[:purchase_request][:cancelled_comment]
    if  @purchase_request.cancel
      flash[:notice] = "La demande d'achat a été annuléé avec succès."
      redirect_to @purchase_request
    else
      render :action => "cancel_form"   
    end
  end
  
end
