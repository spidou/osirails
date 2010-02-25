class EstimateStepController < ApplicationController
  helper :quotes, :press_proofs, :graphic_items
  
  acts_as_step_controller

  def show
    @quotes = @order.quotes
  end
  
  def edit
    @quotes = @order.quotes
  end
  
  def update
    if @step.update_attributes(params[:estimate_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
    end
    render :action => :edit
  end
end
