class QuotationRequestsController < ApplicationController

  helper :quotation_request_supplies, :purchase_orders, :purchase_requests, :purchase_request_supplies, :numbers, :contacts
  
  # GET /customers
  def index
    @quotation_requests = QuotationRequest.pending.paginate(:page => params[:page], :per_page => QuotationRequest::QUOTATIONREQUESTS_PER_PAGE)
  end
  
  # GET /customers/:id
  def show
    @quotation_request = QuotationRequest.find(params[:id])
  end
  
  # GET /quotation_requests/prepare_for_new
  # GET /quotation_requests/prepare_for_new?supplier_choice=true
  def prepare_for_new
    cookies[:chosen_prs_ids] = nil
    @quotation_request = QuotationRequest.new
    if !params[:supplier_choice]
      @suppliers = PurchaseRequestSupply.all_suppliers_for_all_pending_purchase_request_supplies.paginate(:page => params[:page], :per_page => QuotationRequest::QUOTATIONREQUESTS_PER_PAGE)
      @purchase_request_supplies = PurchaseRequestSupply.all.collect{|prs| prs if (!prs.was_cancelled? and (prs.untreated? or prs.during_treatment?))}.compact.sort_by{ |prs| prs.supply.designation if prs.supply}
    else
      cookies[:chosen_prs_ids] = params[:quotation_request][:prs_ids] if params[:quotation_request] and params[:quotation_request][:prs_ids]
      redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    end
  end
  
  # GET /quotation_requests/new
  # GET /quotation_requests/new?supplier_id=:supplier_id
  def new
    if params[:supplier_id] and params[:supplier_id] != ""
      @supplier = Supplier.find(params[:supplier_id])
      @quotation_request = QuotationRequest.new(:supplier_id => @supplier.id)
      if params[:from_supplier_purchase_request]
        purchase_request_supplies = @supplier.merge_purchase_request_supplies
      elsif cookies[:chosen_prs_ids]
        purchase_request_supplies = PurchaseRequestSupply.find_then_merge_purchase_request_supplies(cookies[:chosen_prs_ids].split(",").collect(&:to_i))
      end
      @quotation_request.build_qrs_from_prs(purchase_request_supplies)
    else
      redirect_to :action => :prepare_for_new, :supplier_choice => true
    end
  end
  
  # PUT /quotation_requests/
  def create
    @quotation_request = QuotationRequest.new(params[:quotation_request])
    @quotation_request.creator_id = current_user.id
    if @quotation_request.save
      flash[:notice] = "La demande de devis a été créé avec succès."
      redirect_to @quotation_request
    else
      render :action => "new"
    end
  end
  
  # GET /quotation_requests/:id/:edit
  def edit
    error_access_page(412) unless (@quotation_request = QuotationRequest.find(params[:id])).can_be_edited?
  end
  
  # PUT /quotation_requests/:id
  def update
    if (@quotation_request = QuotationRequest.find(params[:id])).can_be_edited?
      if @quotation_request.update_attributes(params[:quotation_request])
        flash[:notice] = 'La demande de devis a été modifié avec succès'
        redirect_to @quotation_request
      else
        render :action => :edit
      end
    else
      error_access_page(412)
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
