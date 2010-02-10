class InvoicesController < ApplicationController
  helper :orders, :contacts, :payments, :adjustments
  
  acts_as_step_controller :step_name => :invoice_step, :skip_edit_redirection => true
  
  before_filter :detect_invoice
  before_filter :check_invoice_belong_to_order, :except => [ :new, :create ]
  
  after_filter :add_error_in_step_if_invoice_has_errors, :only => [ :create, :update ]
  
  # GET /orders/:order_id/:step/invoices/:id
  # GET /orders/:order_id/:step/invoices/:id.xml
  # GET /orders/:order_id/:step/invoices/:id.pdf
  def show
    respond_to do |format|
      format.xml {
        render :layout => false
      }
      #format.pdf {
      #  unless @invoice.uncomplete?
      #    render :pdf => "invoice_#{@invoice.reference}", :template => "invoices/show.xml.erb", :xsl => "invoice", :path => "assets/pdf/invoices/invoice_#{@invoice.reference}.pdf"
      #  else
      #    error_access_page(403) #FIXME error_access_page seems to failed in format.pdf (nothing append when this code is reached)
      #  end
      #}
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/invoices/new
  def new
    @invoice = @order.invoices.build
    
    if params[:invoice_type]
      error_access_page(400) unless ['deposit', 'status', 'balance', 'asset'].include?(params[:invoice_type])
      
      error_access_page(412) unless @invoice and @invoice.send("can_create_#{params[:invoice_type]}_invoice?")
      
      case params[:invoice_type]
      when 'deposit'
        @invoice = @order.build_deposit_invoice_from_signed_quote
        
        @invoice.creator          = current_user
        @invoice.contacts        << @order.contacts.last unless @order.contacts.empty?
        @invoice.deposit        ||= @invoice.associated_quote.deposit
        @invoice.deposit_amount ||= @invoice.calculate_deposit_amount_according_to_quote_and_deposit
        @invoice.deposit_vat    ||= ConfigurationManager.sales_deposit_tax_coefficient.to_f
        @invoice.due_dates.build(:date => Date.today, :net_to_paid => @invoice.net_to_paid) #TODO remplacer 'Date.today' par la date d'émission de la facture
      when 'status'
        #TODO
      when 'balance'
        #TODO
      when 'asset'
        #TODO
      end
    end
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
  
  private
    # if invoice has errors, the invoice step has also an error to prevent updating of the step status
    def add_error_in_step_if_invoice_has_errors #TODO this method seems to be unreached and untested!
      unless @invoice.errors.empty?
        @step.errors.add_to_base("La facture n'est pas valide")
      end
    end
    
    def detect_invoice
      id = params[:id] || params[:invoice_id]
      @invoice = Invoice.find(id) if id
    end
    
    def check_invoice_belong_to_order
      if !@invoice.new_record? and @order
        error_access_page(404) unless @order.invoices.include?(@invoice)
      end
    end
    
end
