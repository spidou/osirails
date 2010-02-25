class QuotesController < ApplicationController
  helper :orders, :contacts
  # method_permission :edit => ['enable', 'disable']
  
  after_filter :add_error_in_step_if_quote_has_errors, :only => [ :create, :update ]
  
  acts_as_step_controller :step_name => :estimate_step, :skip_edit_redirection => true
  
  # GET /orders/:order_id/:step/quotes/:id
  # GET /orders/:order_id/:step/quotes/:id.xml
  # GET /orders/:order_id/:step/quotes/:id.pdf
  def show
    @quote = Quote.find(params[:id])
    
    if @quote.uncomplete? and params[:format] == "pdf"
      error_access_page(404)
      return
    end
    
    respond_to do |format|
      format.xml {
        render :layout => false
      }
      format.pdf {
        pdf_filename = "quote_#{@quote.public_number}"
        render_pdf(pdf_filename, "quotes/show.xml.erb", "public/fo/style/quote.xsl", "assets/pdf/quotes/#{pdf_filename}.pdf")
      }
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/quotes/new
  def new
    @quote = @order.quotes.build(:validity_delay      => ConfigurationManager.sales_quote_validity_delay,
                                 :validity_delay_unit => ConfigurationManager.sales_quote_validity_delay_unit)
    
    if @quote.can_be_added?
      @quote.contacts << @order.contacts.last unless @order.contacts.empty?
      
      @order.products.each do |product|
        @quote.build_quote_item(:product_id => product.id)
      end
    else
      error_access_page(412)
    end
  end
  
  # POST /orders/:order_id/:step/quotes
  def create
    #@quote = @order.quotes.build(params[:quote])
    @quote = @order.quotes.build # so we can use @quote.order_id in quote.rb
    @quote.attributes = params[:quote]
    
    if @quote.can_be_added?
      @quote.creator = current_user
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
    error_access_page(412) unless (@quote = Quote.find(params[:id])).can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/quotes/:id
  def update
    if (@quote = Quote.find(params[:id])).can_be_edited?
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
    if (@quote = Quote.find(params[:id])).can_be_deleted?
      unless @quote.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression du devis'
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/confirm
  def confirm
    if (@quote = Quote.find(params[:quote_id])).can_be_confirmed?
      unless @quote.confirm
        flash[:error] = "Une erreur est survenue à la validation du devis"
      else
        flash[:notice] = "Le devis a été validé avec succès"
        redirect_to send(@step.original_step.path)
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/cancel
  def cancel
    if (@quote = Quote.find(params[:quote_id])).can_be_cancelled?
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
    error_access_page(412) unless (@quote = Quote.find(params[:quote_id])).can_be_sended?
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/send_to_customer
  def send_to_customer # method 'send' is also defined
    if (@quote = Quote.find(params[:quote_id])).can_be_sended?
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
    error_access_page(412) unless (@quote = Quote.find(params[:quote_id])).can_be_signed?
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/sign
  def sign
    if (@quote = Quote.find(params[:quote_id])).can_be_signed?
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
    if @quote = Quote.find(params[:quote_id]) and @quote.signed?
      url = @quote.order_form.path
      url = File.exists?(url) ? url : @quote.order_form
      
      send_data File.read(url), :filename => "#{@quote.order_form_type.name.downcase.gsub(' ', '_')}_#{@quote.public_number}.pdf", :type => @quote.order_form_content_type, :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  private
    # if quote has errors, the estimate step has also an error to prevent updating of the step status
    def add_error_in_step_if_quote_has_errors #TODO this method seems to be unreached and untested!
      unless @quote.errors.empty?
        @step.errors.add_to_base("Le devis n'est pas valide")
      end
    end
    
    def render_pdf(pdf_filename, template, xsl_path, pdf_path, is_temporary_pdf=false)
      unless File.exist?(pdf_path)
        area_tree_path = Fop.area_tree_from_xml_and_xsl(render_to_string(:template => template, :layout => false), xsl_path, "public/fo/tmp/#{File.basename(pdf_path,".pdf")}.at")  
        
        total_pages = `xpath -e "count(//page)" #{area_tree_path}`.to_i
        offset_value = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/).last.to_i

        File.delete(area_tree_path)
        
        modified_xsl_path = "public/fo/tmp/modified_quote_for_#{File.basename(pdf_path,".pdf")}.xsl"
        
        `cp -f #{xsl_path} #{modified_xsl_path}`

        if total_pages == 1
          optimum_offset_value = 555000
        else
          optimum_offset_value = 715000
        end
        
        if offset_value < optimum_offset_value
          additionnal_offset_value = optimum_offset_value - offset_value
          new_padding = (additionnal_offset_value * 0.0000325) + 0.1
          
          `replace 'id="first-blank-cell" padding-top="0.1cm"' 'padding-top="#{new_padding}cm"' -- #{modified_xsl_path}`
        end
        
        render :pdf => pdf_filename, :template => template, :xsl => modified_xsl_path, :path => pdf_path, :is_temporary_pdf => is_temporary_pdf
     
        File.delete(modified_xsl_path)
      else
        render :pdf => pdf_filename, :path => pdf_path
      end
    end    
end
