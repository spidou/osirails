class InvoicesController < ApplicationController
  helper :orders, :contacts, :payments, :adjustments
  
  acts_as_step_controller :step_name => :invoice_step, :skip_edit_redirection => true
  
  before_filter :find_invoice
  before_filter :check_invoice_belong_to_order, :except => [ :new, :create, :ajax_request_for_invoice_items ]
  
  after_filter :add_error_in_step_if_invoice_has_errors, :only => [ :create, :update ]
  
  # GET /orders/:order_id/:step/invoices/:id
  # GET /orders/:order_id/:step/invoices/:id.xml
  # GET /orders/:order_id/:step/invoices/:id.pdf
  def show
    if !@invoice.can_be_downloaded? and params[:format] == "pdf"
      error_access_page(404)
      return
    end
    
    respond_to do |format|
      format.xml {
        render :layout => false
      }
      format.pdf {
        render_pdf("facture_#{@invoice.reference}", "invoices/show.xml.erb", "public/fo/style/invoice.xsl", "assets/sales/invoices/generated_pdf/#{@invoice.id}.pdf")
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
          delivery_notes = params[:delivery_note_ids].split(",").collect{ |x| DeliveryNote.find_by_id(x) } #OPTIMIZE by using find_some ? (ou find_by_ids)
         
          # return a 404 error if one of the delivery_note_ids is not found, or if one of the delivery_note_ids is not a delivery_note of the order
          unless delivery_notes.select{ |dn| dn.nil? }.empty? and delivery_notes.reject{ |dn| @order.unbilled_delivery_notes.include?(dn) }.empty?
            error_access_page(404)
            return
          end
        else
          delivery_notes << @order.unbilled_delivery_notes.first
        end
          
        @invoice = @order.build_invoice_from( delivery_notes, Invoice::STATUS_INVOICE )
      when 'balance'
        @invoice = @order.build_invoice_from( @order.unbilled_delivery_notes, Invoice::BALANCE_INVOICE )
      when 'asset'
        @invoice.invoice_type = InvoiceType.find_by_name(Invoice::ASSET_INVOICE)
        
        @invoice.invoice_items.build
        
        @invoice.due_dates.build(:date => Date.today + 1.year, :net_to_paid => @invoice.net_to_paid)
      end
    end
    
    @invoice.creator = current_user
    @invoice.contacts << @order.contacts.last unless @order.contacts.empty?
    @invoice.due_dates.build(:date => Date.today + 1.month, :net_to_paid => @invoice.net_to_paid) if @invoice.due_dates.empty?
  end
  
  # POST /orders/:order_id/:step/invoices
  def create
    @invoice = @order.invoices.build # so we can use @invoice.order_id in invoice.rb
    @invoice.attributes = params[:invoice]
    
    if @invoice.can_be_added?
      @invoice.creator = current_user
      if @invoice.save
        flash[:notice] = "La facture a été créée avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :new
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:id/edit
  def edit
    error_access_page(403) unless @invoice.can_be_edited?
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
      error_access_page(403)
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/confirm
  def confirm
    if @invoice.can_be_confirmed?
      unless @invoice.confirm
        flash[:error] = "Une erreur est survenue à la validation de la facture"
      else
        flash[:notice] = "La facture a été validée avec succès"
        redirect_to send(@step.original_step.path)
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/cancel_form
  def cancel_form
    error_access_page(403) unless @invoice.can_be_cancelled?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/cancel
  def cancel
    if @invoice.can_be_cancelled?
      attributes = ( params[:invoice] || {} ).merge(:cancelled_by_id => current_user.id)
      if @invoice.cancel(attributes)
        flash[:notice] = "La facture a été annulée avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :cancel_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/send_form
  def send_form
    error_access_page(403) unless @invoice.can_be_sended?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/abandon_form
  def abandon_form
    error_access_page(403) unless @invoice.can_be_abandoned?
  end
  
  # PUT /orders/:order_id/:step/invoices/:invoice_id/sign
  def abandon
    if @invoice.can_be_abandoned?
      attributes = ( params[:invoice] || {} ).merge(:abandoned_by_id => current_user.id)
      if @invoice.abandon(attributes)
        flash[:notice] = 'La facture a été abandonée (déclarée "sans suite") avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :abandon_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_pay_form
  def factoring_pay_form
    error_access_page(403) unless @invoice.can_be_factoring_paid?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_recover_form
  def factoring_recover_form
    error_access_page(403) unless @invoice.can_be_factoring_recovered?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/factoring_balance_pay_form
  def factoring_balance_pay_form
    error_access_page(403) unless @invoice.can_be_factoring_balance_paid?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/totally_pay_form
  def totally_pay_form
    error_access_page(403) unless @invoice.can_be_totally_paid?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/:invoice_id/due_date_pay_form
  def due_date_pay_form
    error_access_page(403) unless @invoice.can_be_due_date_paid?
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
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/invoices/ajax_request_for_invoice_items/:delivery_note_ids
  # GET /orders/:order_id/:step/invoices/:invoice_id/ajax_request_for_invoice_items/:delivery_note_ids
  def ajax_request_for_invoice_items
    @invoice = Invoice.find_by_id(params[:invoice_id]) || @order.invoices.build
    
    delivery_notes = params[:delivery_note_ids] ? params[:delivery_note_ids].split(",") : []
    
    @invoice.delivery_note_invoice_attributes=(delivery_notes)
    
    @invoice.build_or_update_invoice_items_from_associated_delivery_notes
  end
  
  private
    # if invoice has errors, the invoice step has also an error to prevent updating of the step status
    def add_error_in_step_if_invoice_has_errors #TODO this method seems to be unreached and untested!
      unless @invoice.errors.empty?
        @step.errors.add_to_base("La facture n'est pas valide")
      end
    end
    
    def find_invoice
      id = params[:id] || params[:invoice_id]
      @invoice = Invoice.find(id) if id
    end
    
    def check_invoice_belong_to_order
      if !@invoice.new_record? and @order
        error_access_page(404) unless @order.invoices.include?(@invoice)
      end
    end
    
    def render_pdf(pdf_filename, template, xsl_path, pdf_path, is_temporary_pdf=false)
      unless File.exist?(pdf_path)
        area_tree_path = Fop.area_tree_from_xml_and_xsl(render_to_string(:template => template, :layout => false), xsl_path, "public/fo/tmp/#{File.basename(pdf_path,".pdf")}.at")  
        
        total_pages = `xpath -e "count(//page)" #{area_tree_path}`.to_i
        offset_value = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/).last.to_i

        File.delete(area_tree_path)
        
        modified_xsl_path = "public/fo/tmp/modified_invoice_for_#{File.basename(pdf_path,".pdf")}.xsl"
        
        `cp -f #{xsl_path} #{modified_xsl_path}`

        if total_pages == 1
          optimum_offset_value = 510000 # FIXME This value must change if the size of all elements before the table change
        else
          optimum_offset_value = 700000 # This value should normally be constant
        end
        
        if offset_value < optimum_offset_value
          additionnal_offset_value = optimum_offset_value - offset_value
          new_padding = (additionnal_offset_value * 0.0000325) + 0.1
          
          `replace '<xsl:attribute name="padding-top">1mm</xsl:attribute> <!-- COMMENT FOR DYNAMIC RESIZE OF THE EMPTY LINE, DO NOT REMOVE ME AND DO NOT COPY ME -->' '<xsl:attribute name="padding-top">#{new_padding}cm</xsl:attribute>' -- #{modified_xsl_path}`
        end
        
        render :pdf => pdf_filename, :template => template, :xsl => modified_xsl_path, :path => pdf_path, :is_temporary_pdf => is_temporary_pdf
     
        File.delete(modified_xsl_path)
      else
        render :pdf => pdf_filename, :path => pdf_path
      end
    end  
end
