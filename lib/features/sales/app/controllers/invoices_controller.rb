class InvoicesController < ApplicationController
  include AdjustPdf
  helper :orders, :invoice_items, :sales, :contacts, :payments, :adjustments, :numbers, :address
  
  acts_as_step_controller :step_name => :invoice_step, :skip_edit_redirection => true
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]
  
  before_filter :find_invoice
  before_filter :check_invoice_belong_to_order, :except => [ :new, :create, :ajax_request_for_invoice_items ]
  before_filter :hack_params_for_nested_attributes, :only => [ :update, :create ]
  
  after_filter :add_error_in_step_if_invoice_has_errors, :only => [ :create, :update ]
  
  # GET /orders/:order_id/:step/invoices/:id
  # GET /orders/:order_id/:step/invoices/:id.xml
  # GET /orders/:order_id/:step/invoices/:id.pdf
  def show
    respond_to do |format|
      format.xml {
        build_temporary_reference_line
        render :layout => false
      }
      format.pdf {
        #FIXME don't know why, but for this case, response.headers["Expires"] is always set to 1970, so the file is never get from cache, even when we want it to
        #      we have a good behaviour on press_proofs
        set_cache_buster unless @invoice.can_be_downloaded? # don't allow browser caching when downloading preview
        
        build_temporary_reference_line
        pdf_path = "assets/sales/invoices/generated_pdf/#{@invoice.can_be_downloaded? ? @invoice.id : 'tmp_'+generate_random_id}.pdf" # => "1.pdf" or "tmp_W91OA918.pdf"
        pdf_filename = "#{Invoice.human_name.parameterize.to_s}_#{@invoice.can_be_downloaded? ? @invoice.reference : 'tmp_'+generate_random_id}" # => "invoice_REFINVOICE" or "invoice_tmp_W91OA918"
        render_pdf(pdf_filename, "invoices/show.xml.erb", "invoices/show.xsl.erb", pdf_path, !@invoice.can_be_downloaded?)
      }
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/invoices/new
  def new
    @invoice = @order.invoices.build
    
    if params[:invoice_type]
      unless ['deposit', 'status', 'balance', 'asset'].include?(params[:invoice_type])
        error_access_page(400)
        return
      end
      
      unless @invoice and @invoice.send("can_create_#{params[:invoice_type]}_invoice?")
        error_access_page(412)
        return
      end
      
      case params[:invoice_type]
      when 'deposit'
        @invoice = @order.build_deposit_invoice_from_signed_quote
        
        @invoice.due_dates.build(:date => Date.today, :net_to_paid => @invoice.net_to_paid)
      when 'status'
        delivery_notes = []
        
        if params[:delivery_note_ids]
          delivery_notes = params[:delivery_note_ids].collect{ |x| DeliveryNote.find_by_id(x) }
         
          # return a 404 error if one of the delivery_note_ids is not found, or if one of the delivery_note_ids is not a delivery_note of the order
          unless delivery_notes.select{ |dn| dn.nil? }.empty? and delivery_notes.reject{ |dn| @order.delivery_notes_without_confirmed_invoice.include?(dn) }.empty?
            error_access_page(404)
            return
          end
        end
          
        @invoice = @order.build_invoice_from( delivery_notes, Invoice::STATUS_INVOICE )
        @invoice.build_service_invoice_items_from_unbilled_orders_service_deliveries
      when 'balance'
        @invoice = @order.build_invoice_from( @order.delivery_notes_without_confirmed_invoice, Invoice::BALANCE_INVOICE )
        @invoice.build_service_invoice_items_from_unbilled_orders_service_deliveries
      when 'asset'
        @invoice.invoice_type = InvoiceType.find_by_name(Invoice::ASSET_INVOICE)
        
        @invoice.invoice_items.build
        
        @invoice.due_dates.build(:date => Date.today + 1.year, :net_to_paid => @invoice.net_to_paid)
      end
    end
    
    @invoice.invoice_contact = @order.order_contact
    @invoice.invoicing_actor = current_user.employee
    @invoice.due_dates.build(:date => Date.today + 1.month, :net_to_paid => @invoice.net_to_paid) if @invoice.due_dates.empty?
  end
  
  # POST /orders/:order_id/:step/invoices
  def create
    @invoice = @order.invoices.build # so we can use @invoice.order_id in invoice.rb
    @invoice.attributes = params[:invoice]
    
    if @invoice.can_be_added?
      if @invoice.save
        flash[:notice] = "La facture a été créée avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :new
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:id/edit
  def edit
    error_access_page(412) unless @invoice.can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/invoices/:id
  def update
    if @invoice.can_be_edited?
      if @invoice.update_attributes(params[:invoice])
        flash[:notice] = 'La facture a été modifiée avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /orders/:order_id/:step/invoices/:id
  def destroy
    if @invoice.can_be_deleted?
      unless @invoice.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression de la facture'
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/confirm
  def confirm
    if @invoice.can_be_confirmed?
      if @invoice.confirm
        flash[:notice] = "La facture a été validée avec succès"
        redirect_to send(@step.original_step.path)
      else
        flash[:error] = "Une erreur est survenue à la validation de la facture (attention, les échéances doivent être postérieures à la date d'émission de la facture)"
        redirect_to edit_order_invoicing_step_invoice_step_invoice_path(@order, @invoice)
        #render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/cancel_form
  def cancel_form
    error_access_page(412) unless @invoice.can_be_cancelled?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/cancel
  def cancel
    if @invoice.can_be_cancelled?
      if @invoice.cancel(params[:invoice])
        flash[:notice] = "La facture a été annulée avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :cancel_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/send_form
  def send_form
    error_access_page(412) unless @invoice.can_be_sended?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/send_to_customer
  def send_to_customer # method 'send' is also defined
    if @invoice.can_be_sended?
      if @invoice.send_to_customer(params[:invoice])
        flash[:notice] = 'La facture a été modifiée avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :send_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/abandon_form
  def abandon_form
    error_access_page(412) unless @invoice.can_be_abandoned?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/sign
  def abandon
    if @invoice.can_be_abandoned?
      if @invoice.abandon(params[:invoice])
        flash[:notice] = 'La facture a été abandonée (déclarée "sans suite") avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :abandon_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_pay_form
  def factoring_pay_form
    error_access_page(412) unless @invoice.can_be_factoring_paid?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/factoring_pay
  def factoring_pay
    if @invoice.can_be_factoring_paid?
      if @invoice.factoring_pay(params[:invoice])
        flash[:notice] = 'La facture a été signalée comme "payée partiellement par le FACTOR" avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :factoring_pay_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_recover_form
  def factoring_recover_form
    error_access_page(412) unless @invoice.can_be_factoring_recovered?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/factoring_recover
  def factoring_recover
    if @invoice.can_be_factoring_recovered?
      if @invoice.factoring_recover(params[:invoice])
        flash[:notice] = 'La facture a été signalée comme "définancée par le FACTOR" avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :factoring_recover_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_balance_pay_form
  def factoring_balance_pay_form
    error_access_page(412) unless @invoice.can_be_factoring_balance_paid?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/factoring_balance_pay
  def factoring_balance_pay
    if @invoice.can_be_factoring_balance_paid?
      if @invoice.factoring_balance_pay(params[:invoice])
        flash[:notice] = 'La facture a été signalée comme "payée totalement par le FACTOR" avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :factoring_balance_pay_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/totally_pay_form
  def totally_pay_form
    error_access_page(412) unless @invoice.can_be_totally_paid?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/totally_pay
  def totally_pay
    if @invoice.can_be_totally_paid?
      if @invoice.totally_pay(params[:invoice])
        flash[:notice] = 'La facture a été signalée comme "payée totalement par le CLIENT" avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :totally_pay_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/due_date_pay_form
  def due_date_pay_form
    error_access_page(412) unless @invoice.can_be_due_date_paid?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/due_date_pay
  def due_date_pay
    if @invoice.can_be_due_date_paid?
      if @invoice.due_date_pay(params[:invoice])
        flash[:notice] = 'La facture a été signalée comme "payée partiellement par le CLIENT" avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :due_date_pay_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/ajax_request_for_invoice_items/:delivery_note_ids
  # GET /orders/:order_id/:step/invoices/:invoice_id/ajax_request_for_invoice_items/:delivery_note_ids
  def ajax_request_for_invoice_items
    delivery_notes = params[:delivery_note_ids] ? params[:delivery_note_ids].split(",") : []
    
    @invoice ||= Invoice.find_by_id(params[:invoice_id]) || @order.invoices.build
    @invoice.delivery_note_invoice_attributes=(delivery_notes)
    @invoice.build_or_update_invoice_items_from_associated_delivery_notes
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_nested_attributes # checklist_responses, documents
      # hack for has_contact :invoice_contact
      if params[:invoice][:invoice_contact_attributes] and params[:contact]
        params[:invoice][:invoice_contact_attributes][:number_attributes] = params[:contact][:number_attributes]
      end
      params.delete(:contact)
    end
    
    # if invoice has errors, the invoice step has also an error to prevent updating of the step status
    def add_error_in_step_if_invoice_has_errors #TODO this method seems to be unreached and untested!
      unless @invoice.errors.empty?
        @step.errors.add_to_base("La facture n'est pas valide")
      end
    end
    
    def find_invoice
      if id = params[:id] || params[:invoice_id]
        @invoice = Invoice.find(id)
        error_access_page(404) unless @order and @invoice.order_id == @order.id
      end
    end
    
    def check_invoice_belong_to_order
      if !@invoice.new_record? and @order
        error_access_page(404) unless @order.invoices.include?(@invoice)
      end
    end
    
    def render_pdf(pdf_filename, xml_template, xsl_template, pdf_path, is_temporary_pdf=false)
      unless File.exist?(pdf_path)  
        area_tree_path = Fop.area_tree_from_xml_and_xsl(render_to_string(:template => xml_template, :layout => false), render_to_string(:template => xsl_template, :layout => false), "public/fo/tmp/#{File.basename(pdf_path,".pdf")}.at")
        adjust_pdf_last_footline(area_tree_path,510000,700000) 
        adjust_pdf_intermediate_footlines(area_tree_path,510000,700000)
        adjust_pdf_report(area_tree_path) 
        render :pdf => pdf_filename, :xml_template => xml_template, :xsl_template => xsl_template , :path => pdf_path, :is_temporary_pdf => is_temporary_pdf
        File.delete(area_tree_path)
      else
        render :pdf => pdf_filename, :path => pdf_path
      end
    end 
    
    def build_temporary_reference_line
      lines = ([@invoice.signed_quote] + @invoice.delivery_notes).collect do |item|
        "#{item.class.human_name} n°#{item.reference}"
      end.join("\n")
      
      @invoice.invoice_items.unshift InvoiceItem.new(:name => "Pièces d'origine :", :description => lines)
    end
end
