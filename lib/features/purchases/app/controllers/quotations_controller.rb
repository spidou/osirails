class QuotationsController < ApplicationController
  helper :quotation_supplies, :purchase_request_supplies, :contacts, :numbers
  
  # GET /quotations/
  def index
    @pending_quotations = Quotation.pending.paginate(:page => params[:page], :per_page => Quotation::QUOTATIONS_PER_PAGE)
  end
  
  # GET /quotations/:id
  def show
    @quotation = Quotation.find(params[:id])
  end
  
  # GET /quotations/prepare_for_new
  # GET /quotations/prepare_for_new?supplier_choice=true
  def prepare_for_new
    cookies[:chosen_prs_ids] = nil
    @quotation = Quotation.new
    if !params[:supplier_choice]
      @suppliers = PurchaseRequestSupply.all_suppliers_for_all_pending_purchase_request_supplies.paginate(:page => params[:page], :per_page => Quotation::QUOTATIONS_PER_PAGE)
      @purchase_supplies = PurchaseRequestSupply.all.collect{|prs| prs if(!prs.was_cancelled? and (prs.untreated? or prs.during_treatment?))}.compact.sort_by{ |prs| prs.supply.designation if prs.supply}
    else
      cookies[:chosen_prs_ids] = params[:quotation][:prs_ids] if params[:quotation] and params[:quotation][:prs_ids]
      redirect_to :action => :new, :supplier_id => params[:supplier_id] if params[:supplier_id]
    end
  end
  
  # GET /quotations/new
  # GET /quotations/new?supplier_id=:supplier_id
  def new
    if params[:supplier_id] and params[:supplier_id] != ""
      @supplier = Supplier.find(params[:supplier_id])
      if params[:from_purchase_request]
        purchase_request_supplies = @supplier.merge_purchase_request_supplies
      elsif cookies[:chosen_prs_ids]
        purchase_request_supplies = PurchaseRequestSupply.find_then_merge_purchase_request_supplies(cookies[:chosen_prs_ids].split(",").collect(&:to_i))
      end
      
      if cookies[:quotation]
        @quotation = cookies[:quotation]
        cookies[:quotation] = nil
        @quotation.supplier_id = @supplier.id
      else
        @quotation = Quotation.new(:supplier_id => @supplier.id)
        @quotation.build_qs_from_prs(purchase_request_supplies)
      end
    elsif params[:supplier_id]
      redirect_to :action => :prepare_for_new, :supplier_choice => true
    else
      redirect_to :action => :prepare_for_new, :supplier_choice => true
    end
  end
  
  # PUT /quotations/
  def create
    @quotation = Quotation.new(params[:quotation])
    @quotation.creator_id = current_user.id
    if @quotation.save
      flash[:notice] = "Le devis a été créé avec succès."
      redirect_to @quotation
    else
      render :action => :new
    end
  end
  
  # GET /quotations/:id/:edit
  def edit
    error_access_page(412) unless (@quotation = Quotation.find(params[:id])).can_be_edited?
  end
  
  # PUT /quotations/:id
  def update
    if(@quotation = Quotation.find(params[:id])).can_be_edited?
      if @quotation.update_attributes(params[:quotation])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to @quotation
      else
        render :controller => :quotations, :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /quotations/:quotation_id
  def destroy
    if (@quotation = Quotation.find(params[:id])).can_be_destroyed?
      unless @quotation.destroy
        flash[:error] = 'Une erreur est survenue lors de la suppression du devis'
      end
      flash[:notice] = 'La suppression deu devis a été effectué avec succès'
      redirect_to quotations_path
    else
      error_access_page(412)
    end
  end
  
  def make_copy
    @original_quotation = Quotation.find(params[:quotation_id])
    redirect_to :action => :new, :copy => @original_quotation.id
  end
  
  # GET /quotations/:quotation_id/sign  
  def sign
    @quotation = Quotation.find(params[:quotation_id])
    if Quotation.can_sign?(current_user) and @quotation.can_be_signed?
      @quotation.attributes = params[:quotation]
      if @quotation.sign
        flash[:notice] = 'Le devis a bien été signalé comme signé'
        redirect_to quotation_path(@quotation)
      else
        render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /quotations/:quotation_id/send_to_supplier  
  def send_to_supplier
    @quotation = Quotation.find(params[:quotation_id])
    if Quotation.can_send_to_supplier?(current_user) and @quotation.can_be_send_to_supplier?
      @quotation.attributes = params[:quotation]
      if @quotation.send_to_supplier
        flash[:notice] = 'Le devis a bien été signalé comme envoyé au fournisseur'
        redirect_to quotation_path(@quotation)
      else
        render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  def quotation_supply
    @supply = Supply.find(params[:supply_id])
    @quotation_supply = QuotationSupply.new(:supply_id => @supply.id)
    render :partial => 'quotation_supplies/quotation_supply', :object => @quotation_supply, :locals => {:quotation => @quotation_supply.quotation || Quotation.new}
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
    if params[:quotation_id] and (params[:quotation_id] ||= "")
      @quotation = Quotation.find(params[:quotation_id])
    else
      @quotation = Quotation.new
    end
    render :partial => 'contacts/contact_picker', :object => @quotation, :locals => { :contact_key => 'supplier_contact', :contacts_owners => [@supplier], :contact_list => @supplier.contacts }
  end
  
  private
    def hack_params_for_quotation_nested_attributes
      # hack for has_contact :supplier_contacts
      if params[:quotation][:supplier_contact_attributes] and params[:contact]
        params[:quotation][:supplier_contact_attributes][:number_attributes] = params[:contact][:number_attributes]
      end
      params.delete(:contact)
    end
end
