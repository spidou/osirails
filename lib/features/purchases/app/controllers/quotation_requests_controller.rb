class QuotationRequestsController < ApplicationController

  helper :quotation_request_supplies, :purchase_orders, :purchase_requests, :purchase_request_supplies
  
  # GET /quotation_requests/prepare_for_new
  # GET /quotation_requests/prepare_for_new?supplier_choice=true
  def prepare_for_new
    @quotation_request = QuotationRequest.new
    redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    if !params[:supplier_choice] and !params[:supplier_id]
      @suppliers = PurchaseRequestSupply.all_suppliers_for_all_pending_purchase_request_supplies.paginate(:page => params[:page], :per_page => QuotationRequest::REQUESTS_PER_PAGE)
      @purchase_request_supplies = PurchaseRequestSupply.pending_and_merged_by_supply_id
    end
    @chosen_purchase_request_supplies ||= []
  end
  
  # GET /quotation_requests/new
  # GET /quotation_requests/new?supplier_id=:supplier_id
  def new
    unless params[:supplier_id] and params[:supplier_id] != ""
      redirect_to :action => :prepare_for_new, :supplier_choice => true
    else
      @supplier = Supplier.find(params[:supplier_id])
      @quotation_request = QuotationRequest.new(:supplier_id => @supplier.id)
      @quotation_request.build_quotation_request_supplies_from_purchase_request_supplies(@supplier.merge_purchase_request_supplies) if params[:from_purchase_request]
    end
  end
  
  # PUT /purchase_orders/
  def create
    @quotation_request = QuotationRequest.new(params[:quotation_request])
    @quotation_request.creator_id = current_user.id
    if @purchase_order.save
      flash[:notice] = "La demande de devis a été créé avec succès."
      redirect_to @quotation_request
    else
      render :action => "new"
    end
  end
  
  def quotation_request_supply
    @supply = Supply.find(params[:supply_id])
    @quotation_request_supply = QuotationRequestSupply.new(:supply_id => @supply.id)
    render :partial => 'quotation_request_supplies/quotation_request_supply', :object => @quotation_request_supply
  end
  
  def auto_complete_for_supply
    keywords = params[:supply][:reference].split(" ").collect(&:strip)
    @items = []
    @supplies = Supply.all
    keywords.each do |keyword|
      keyword = Regexp.new(keyword, Regexp::IGNORECASE)
      result = @supplies.select{|s| s.name =~ keyword or s.designation =~ keyword or s.reference =~ keyword}
      @items = @items.empty? ? result : @items & result
    end 
    render :partial => 'purchase_orders/search_supply_reference_auto_complete', :object => @items, :locals => { :fields => "designation", :keywords => keywords }
  end
end
