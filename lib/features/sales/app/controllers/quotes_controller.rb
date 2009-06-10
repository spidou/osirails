class QuotesController < ApplicationController
  helper :orders, :contacts
  
  after_filter :add_error_in_step_if_quote_has_errors, :only => [ :create, :update ]
  
  acts_as_step_controller :step_name => :estimate_step, :skip_edit_redirection => true
  
  def show
    if Quote.can_view?(current_user)
      @quote = Quote.find(params[:id])
      
      respond_to do |format|
        format.pdf {
          pdf = render_pdf
          if pdf
            send_data pdf, :filename => "devis_#{@quote.id}.pdf", :disposition => 'attachment'
          else
            error_access_page(500)
          end
        }
        format.html { }
      end
    else
      error_access_page(403)
    end
  end
  
  def new
    if Quote.can_add?(current_user)
      @quote = @order.commercial_step.estimate_step.quotes.build
      @quote.contacts << @order.contacts.last unless @order.contacts.empty?
    else
      error_access_page(403)
    end
  end
  
  def create
    if Quote.can_add?(current_user)
      @quote = @order.commercial_step.estimate_step.quotes.build(params[:quote])
      @quote.creator = current_user
      if @quote.save
        flash[:notice] = "Le devis a été ajout&eacute; avec succ&egrave;s"
        redirect_to order_estimate_step_quote_path(@order, @quote)
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end
  
  def edit
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:id])
    end
  end
  
  def update
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:id])
      
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
  
  # if quote has errors, the step estimate has also an error to prevent updating of the step status
  def add_error_in_step_if_quote_has_errors
    unless @quote.errors.empty?
      @step.errors.add_to_base("Le devis n'est pas valide")
    end
  end
  
end
