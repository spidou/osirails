class QuotationRequestsController < ApplicationController

  helper :quotation_request_supplies, :purchase_orders, :purchase_requests, :purchase_request_supplies, :numbers, :contacts
  
  before_filter :hack_params_for_quotation_request_nested_attributes, :only => [ :update, :create ]
  
  # GET /quotation_requests
  def index
    @pending_quotation_requests = QuotationRequest.pending.paginate(:page => params[:page], :per_page => QuotationRequest::QUOTATIONREQUESTS_PER_PAGE)
  end
  
  # GET /quotation_requests/:id
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
      @purchase_request_supplies = PurchaseRequestSupply.all.collect{|prs| prs if(!prs.was_cancelled? and (prs.untreated? or prs.during_treatment?))}.compact.select(&:supply).sort_by{ |prs| prs.supply.designation}
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
      if params[:from_purchase_request]
        purchase_request_supplies = @supplier.merge_purchase_request_supplies
      elsif cookies[:chosen_prs_ids]
        purchase_request_supplies = PurchaseRequestSupply.find_then_merge_purchase_request_supplies(cookies[:chosen_prs_ids].split(",").collect(&:to_i))
      end
      
      if cookies[:quotation_request]
        @quotation_request = cookies[:quotation_request]
        cookies[:quotation_request] = nil
        @quotation_request.supplier_id = @supplier.id
      else
        @quotation_request = QuotationRequest.new(:supplier_id => @supplier.id)
        @quotation_request.build_qrs_from_prs(purchase_request_supplies)
      end
    elsif params[:review]
      original_quotation_request = QuotationRequest.find(params[:review])
      if original_quotation_request.can_be_reviewed?
        @quotation_request = original_quotation_request.build_prefilled_child
        @supplier = @quotation_request.supplier
      else
        error_access_page(412)
      end
    elsif params[:copy]
      original_quotation_request = QuotationRequest.find(params[:copy])
      @quotation_request = original_quotation_request.build_copy
      @supplier = @quotation_request.supplier
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
      params[:quotation_request][:similar_id] ? (render :controller => :quotation_requests, :action => :send_to_another_supplier_form) : (render :action => :new)
    end
  end
  
  # GET /quotation_requests/:id/:edit
  def edit
    error_access_page(412) unless (@quotation_request = QuotationRequest.find(params[:id])).can_be_edited?
  end
  
  # PUT /quotation_requests/:id
  def update
    if(@quotation_request = QuotationRequest.find(params[:id])).can_be_edited?
      if @quotation_request.update_attributes(params[:quotation_request])
        flash[:notice] = 'La demande de devis a été modifié avec succès'
        redirect_to @quotation_request
      else
        render :controller => :quotation_requests, :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /quotation_requests/:quotation_request_id
  def destroy
    if (@quotation_request = QuotationRequest.find(params[:id])).can_be_destroyed?
      unless @quotation_request.destroy
        flash[:error] = 'Une erreur est survenue lors de la suppression de la demande de devis'
      end
      flash[:notice] = 'La suppression de la demande de devis a été effectué avec succès'
      redirect_to quotation_requests_path
    else
      error_access_page(412)
    end
  end
  
  def make_copy
    @original_quotation_request = QuotationRequest.find(params[:quotation_request_id])
    redirect_to :action => :new, :copy => @original_quotation_request.id
  end
  
  def review
    if(@reviewed_quotation_request = QuotationRequest.find(params[:quotation_request_id])).can_be_reviewed?
      redirect_to :action => :new, :review => @reviewed_quotation_request.id
    else
      error_access_page(412)
    end
  end
  
  def send_to_another_supplier
    if(@quotation_request = QuotationRequest.find(params[:quotation_request_id])).can_be_sent_to_another_supplier?
      redirect_to quotation_request_send_to_another_supplier_form_path(@quotation_request), :supplier_choice => :true, :send_to_another_supplier => @quotation_request.id
    else
      error_access_page(412)
    end
  end
  
  def send_to_another_supplier_form
    if (@original_quotation_request = QuotationRequest.find(params[:quotation_request_id])).can_be_sent_to_another_supplier?
      @quotation_request = @original_quotation_request.build_prefilled_similar
    else
      error_access_page(412)
    end 
  end
  
  # GET /quotation_requests/:quotation_request_id/confirm  
  def confirm
    @quotation_request = QuotationRequest.find(params[:quotation_request_id])
    if @quotation_request.can_be_confirmed?
      @quotation_request.attributes = params[:quotation_request]
      if @quotation_request.confirm
        flash[:notice] = 'La confirmation de votre demande de devis a été effectuée avec succès'
        redirect_to quotation_request_path(@quotation_request)
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
    render :partial => 'quotation_request_supplies/quotation_request_supply', :object => @quotation_request_supply, :locals => {:quotation_request => @quotation_request_supply.quotation_request || QuotationRequest.new}
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
  
  def update_supplier_contacts
    return unless (supplier_id = params[:supplier_id].to_i)
    @supplier = Supplier.find(supplier_id)
    if params[:quotation_request_id] and (params[:quotation_request_id] != "")
      @quotation_request = QuotationRequest.find(params[:quotation_request_id])
    else
      @quotation_request = QuotationRequest.new
    end
    render :partial => 'contacts/contact_picker', :object => @quotation_request, :locals => { :contact_key => 'supplier_contact', :contacts_owners => [@supplier], :contact_list => @supplier.contacts, :div_id => "quotation_request_supplier_contact" }
  end
  
  private
    def hack_params_for_quotation_request_nested_attributes
      # hack for has_contact :supplier_contacts
      if params[:quotation_request][:supplier_contact_attributes] and params[:contact]
        params[:quotation_request][:supplier_contact_attributes][:number_attributes] = params[:contact][:number_attributes]
      end
      params.delete(:contact)
    end
end
