class QuotesController < ApplicationController
  include AdjustPdf
  helper :orders, :quote_items, :sales, :contacts, :numbers, :address, :products
  # method_permission :edit => ['enable', 'disable']
  
  acts_as_step_controller :step_name => :quote_step, :skip_edit_redirection => true
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]
  
  before_filter :find_quote
  before_filter :hack_params_for_nested_attributes, :only => [ :update, :create ]
  
  after_filter :add_error_in_step_if_quote_has_errors, :only => [ :create, :update ]
  
  set_journalization_actor [:create, :update, :confirm, :send_to_customer, :sign]
  
  # GET /orders/:order_id/:step/quotes/:id
  # GET /orders/:order_id/:step/quotes/:id.xml
  # GET /orders/:order_id/:step/quotes/:id.pdf
  def show
    respond_to do |format|
      format.xsl {
        render :layout => false
      }
      format.xml {
        render :layout => false
      }
      format.pdf {
        #FIXME don't know why, but for this case, response.headers["Expires"] is always set to 1970, so the file is never get from cache, even when we want it to
        #      we have a good behaviour on press_proofs
        set_cache_buster unless @quote.can_be_downloaded? # don't allow browser caching when downloading preview
        
        pdf_path = "assets/sales/quotes/generated_pdf/#{@quote.can_be_downloaded? ? @quote.id : 'tmp_'+generate_random_id}.pdf" # => "1.pdf" or "tmp_W91OA918.pdf"
        pdf_filename = "#{Quote.human_name.parameterize.to_s}_#{@quote.can_be_downloaded? ? @quote.reference : 'tmp_'+generate_random_id}" # => "quote_REFQUOTE" or "quote_tmp_W91OA918"
        render_pdf(pdf_filename, "quotes/show.xml.erb", "quotes/show.xsl.erb", pdf_path, !@quote.can_be_downloaded?)
      }
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/quotes/new
  def new
    @quote = @order.quotes.build(:validity_delay      => ConfigurationManager.sales_quote_validity_delay,
                                 :validity_delay_unit => ConfigurationManager.sales_quote_validity_delay_unit)
    if @quote.can_be_added?
      @quote.quote_contact = @order.order_contact
      @quote.commercial_actor = current_user.employee
      
      @order.end_products.each do |end_product|
        @quote.build_quote_item(:quotable_type  => "EndProduct",
                                :quotable_id    => end_product.id)
      end
      @order.orders_service_deliveries.each do |service|
        @quote.build_quote_item(:quotable_type  => "OrdersServiceDelivery",
                                :quotable_id    => service.id)
      end
    else
      error_access_page(412)
    end
  end
  
  # POST /orders/:order_id/:step/quotes
  def create
    @quote = @order.quotes.build # Quote#quote_item_attributes= needs order_id, so we build the quote from the order to have order_id before all other attributes
    @quote.attributes = params[:quote]
    
    if @quote.can_be_added?
      if @quote.save
        flash[:notice] = "Le devis a été créé avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :new
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:id/edit
  def edit
    error_access_page(412) unless @quote.can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/quotes/:id
  def update
    if @quote.can_be_edited?
      if @quote.update_attributes(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /orders/:order_id/:step/quotes/:id
  def destroy
    if @quote.can_be_deleted?
      unless @quote.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression du devis'
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  def preview
    @quote = @order.quotes.build
    @quote.attributes = params[:quote]
    pdf_filename = "temp_quote_#{Time.now.strftime("%d%m%y%H%M%S")}"
    render_pdf(pdf_filename, "quotes/show.xml.erb", "public/fo/style/quote.xsl", "assets/pdf/quotes/#{pdf_filename}.pdf", true)
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/confirm
  def confirm
    if @quote.can_be_confirmed?
      if @quote.confirm
        flash[:notice] = "Le devis a été validé avec succès"
      else
        flash[:error] = "Une erreur est survenue à la validation du devis"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/cancel
  def cancel
    if @quote.can_be_cancelled?
      unless @quote.cancel
        flash[:error] = "Une erreur est survenue à l'annulation du devis"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/send_form
  def send_form
    error_access_page(412) unless @quote.can_be_sended?
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/send_to_customer
  def send_to_customer # method 'send' is also defined
    if @quote.can_be_sended?
      if @quote.send_to_customer(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :send_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/sign_form
  def sign_form
    error_access_page(412) unless @quote.can_be_signed?
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/sign
  def sign
    if @quote.can_be_signed?
      if @quote.sign(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :action => :sign_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/order_form
  def order_form
    if @quote.signed?
      url = @quote.order_form.path
      url = File.exists?(url) ? url : @quote.order_form
      
      send_data File.read(url), :filename => "#{@quote.order_form_type.name.downcase.gsub(' ', '_')}_#{@quote.reference}.pdf", :type => @quote.order_form_content_type, :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/new_quote_item?reference_object_type=:reference_object_type&reference_object_id=:reference_object_id (AJAX)
  def new_quote_item
    quote_item = QuoteItem.new(:reference_object_type => params[:reference_object_type].to_s,
                               :reference_object_id   => params[:reference_object_id].to_i,
                               :quotable_type         => Quote::QUOTABLES_REFERENCES.index(params[:reference_object_type].to_s))
    render :partial => 'quote_items/quote_item', :object => quote_item
  end
  
  private
    def find_quote
      if id = params[:id] || params[:quote_id]
        @quote = Quote.find(id)
        error_access_page(404) unless @order and @quote.order_id == @order.id
      end
    end
    
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_nested_attributes # checklist_responses, documents
      # hack for has_contact :quote_contact
      if params[:quote][:quote_contact_attributes] and params[:contact]
        params[:quote][:quote_contact_attributes][:number_attributes] = params[:contact][:number_attributes]
      end
      params.delete(:contact)
    end
    
    # if quote has errors, the quote step has also an error to prevent updating of the step status
    def add_error_in_step_if_quote_has_errors #TODO this method seems to be unreached and untested!
      unless @quote.errors.empty?
        @step.errors.add_to_base("Le devis n'est pas valide")
      end
    end
    
    def render_pdf(pdf_filename, xml_template, xsl_template, pdf_path, is_temporary_pdf=false)
      unless File.exist?(pdf_path)  
        area_tree_path = Fop.area_tree_from_xml_and_xsl(render_to_string(:template => xml_template, :layout => false), render_to_string(:template => xsl_template, :layout => false), "public/fo/tmp/#{File.basename(pdf_path,".pdf")}.at")
        adjust_pdf_last_footline(area_tree_path,500000,710000) 
        adjust_pdf_intermediate_footlines(area_tree_path,500000,710000)
        adjust_pdf_report(area_tree_path)
        render :pdf => pdf_filename, :xml_template => xml_template, :xsl_template => xsl_template , :path => pdf_path, :is_temporary_pdf => is_temporary_pdf
        File.delete(area_tree_path)
      else
        render :pdf => pdf_filename, :path => pdf_path
      end
    end
end
