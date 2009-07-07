class QuotesController < ApplicationController
  helper :orders, :contacts
  # method_permission :edit => ['enable', 'disable']
  
  after_filter :add_error_in_step_if_quote_has_errors, :only => [ :create, :update ]
  
  acts_as_step_controller :step_name => :estimate_step, :skip_edit_redirection => true
  
  # GET /orders/:order_id/:step/quotes/:quote_id
  def show
    if Quote.can_view?(current_user)
      @quote = Quote.find(params[:id])
      
      respond_to do |format|
        format.pdf {
          unless @quote.uncomplete?
            pdf = render_pdf
            if pdf
              send_data pdf, :filename => "devis_#{@quote.public_number}.pdf", :type => 'application/pdf', :disposition => 'attachment'
            else
              error_access_page(500)
            end
          else
            error_access_page(403) #FIXME error_access_page seems to failed in format.pdf (nothing append when this code is reached)
          end
        }
        format.html { }
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/new
  def new
    if Quote.can_add?(current_user)
      @quote = @order.commercial_step.estimate_step.quotes.build(:validity_delay      => ConfigurationManager.sales_quote_validity_delay,
                                                                 :validity_delay_unit => ConfigurationManager.sales_quote_validity_delay_unit)
      @quote.contacts << @order.contacts.last unless @order.contacts.empty?
    else
      error_access_page(403)
    end
  end
  
  # POST /orders/:order_id/:step/quotes/:quote_id
  def create
    if Quote.can_add?(current_user)
      @quote = @order.commercial_step.estimate_step.quotes.build(params[:quote])
      @quote.creator = current_user
      if @quote.save
        flash[:notice] = "Le devis a été créé avec succès"
        redirect_to order_estimate_step_quote_path(@order, @quote)
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/edit
  def edit
    unless Quote.can_edit?(current_user) and (@quote = Quote.find(params[:id])).can_be_edited?
      error_access_page(403)
    end
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id
  def update
    if Quote.can_edit?(current_user) and (@quote = Quote.find(params[:id])).can_be_edited?
      if @quote.update_attributes(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to order_estimate_step_quote_path(@order, @quote)
      else
        render :controller => 'quotes', :action => 'edit'
      end
    else
      error_access_page(422)
    end
  end
  
  # DELETE /orders/:order_id/:step/quotes/:quote_id
  def destroy
    if Quote.can_delete?(current_user) and (@quote = Quote.find(params[:id])).can_be_deleted?
      unless @quote.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression du devis'
      end
      redirect_to(order_estimate_step_path(@order))
    else
      error_access_page(422)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/validate
  def validate
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:quote_id])
      unless @quote.validate_quote
        flash[:error] = "Une erreur est survenue à la validation du devis"
      end
      redirect_to order_estimate_step_path(@order)
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/invalidate
  def invalidate
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:quote_id])
      unless @quote.invalidate_quote
        flash[:error] = "Une erreur est survenue à l'invalidation du devis"
      end
      redirect_to order_estimate_step_path(@order)
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/send_form
  def send_form
    unless Quote.can_edit?(current_user) and (@quote = Quote.find(params[:quote_id])).can_be_sended?
      error_access_page(403)
    end
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/send_to_customer
  def send_to_customer # method 'send' is also defined
    if Quote.can_edit?(current_user) and (@quote = Quote.find(params[:quote_id])).can_be_sended?
      #if @quote.update_attributes(params[:quote]) and @quote.send_to_customer!
      #  flash[:notice] = 'Le devis a été modifié avec succès'
      #  redirect_to order_estimate_step_path(@order)
      #else
      #  render :action => :send_form
      #end
      if @quote.send_quote(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to order_estimate_step_path(@order)
      else
        render :action => :send_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/sign_form
  def sign_form
    unless Quote.can_edit?(current_user) and (@quote = Quote.find(params[:quote_id])).can_be_signed?
      error_access_page(403)
    end
  end
  
  # PUT /orders/:order_id/:step/quotes/:quote_id/sign
  def sign
    if Quote.can_edit?(current_user) and (@quote = Quote.find(params[:quote_id])).can_be_signed?
      if @quote.sign_quote(params[:quote])
        flash[:notice] = 'Le devis a été modifié avec succès'
        redirect_to order_estimate_step_path(@order)
      else
        render :action => :sign_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/quotes/:quote_id/order_form
  def order_form
    if Quote.can_view?(current_user)
      if @quote = Quote.find(params[:quote_id]) and @quote.signed?
        url = @quote.order_form.path
        url = File.exists?(url) ? url : @quote.order_form
        
        send_data File.read(url), :filename => "#{@quote.order_form_type.name.downcase.gsub(' ', '_')}_#{@quote.public_number}.pdf", :type => @quote.order_form_content_type, :disposition => 'attachment'
      else
        error_access_page(404)
      end
    else
      error_access_page(403)
    end
  end
  
  private
    # if quote has errors, the estimate step has also an error to prevent updating of the step status
    def add_error_in_step_if_quote_has_errors #TODO this method seems to be unreached and untested!
      unless @quote.errors.empty?
        @step.errors.add_to_base("Le devis n'est pas valide")
      end
    end
  
end
