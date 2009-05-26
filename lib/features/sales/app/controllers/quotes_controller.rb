class QuotesController < ApplicationController
  helper :orders
  
  after_filter :add_error_in_step_if_quote_has_errors, :only => [ :create, :update ]
  
  acts_as_step_controller :step_name => :step_estimate

  def index
    if Quote.can_list?(current_user)
      @quotes = @order.step_commercial.step_estimate.quotes
      redirect_to new_order_step_estimate_quote_path if @quotes.empty?
    else
      error_access_page(403)
    end
  end
  
  def show
    if Quote.can_view?(current_user)
      @quote = Quote.find(params[:id])
      pdf = render_pdf
      if pdf
        send_data pdf, :filename => "devis_#{@quote.id}.pdf", :disposition => 'attachment'
      else
        error_access_page(500)
      end
    else
      error_access_page(403)
    end
  end
  
  def new
    if Quote.can_add?(current_user)
      @quote = @order.step_commercial.step_estimate.quotes.build
    else
      error_access_page(403)
    end
  end
  
  def create
    if Quote.can_add?(current_user)
      @quote = @order.step_commercial.step_estimate.quotes.build(params[:quote])
      @quote.creator = current_user
      if @quote.save
        flash[:notice] = "Le devis a été ajout&eacute; avec succ&egrave;s"
        redirect_to order_step_estimate_path(@order)
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
        redirect_to edit_order_step_estimate_path(@order)
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
