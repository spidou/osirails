class QuoteStepController < ApplicationController
  helper :quotes, :press_proofs, :graphic_items
  
  acts_as_step_controller
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]

  def show
    @quotes = @order.quotes
  end
  
  def edit
    @quotes = @order.quotes
  end
  
  def update
    if @step.update_attributes(params[:quote_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
    end
    render :action => :edit
  end
end
