class StepEstimateController < ApplicationController
  helper :quotes
  
  acts_as_step_controller

  def show
    @quotes = @order.step_commercial.step_estimate.quotes
  end
  
  def edit
    @quotes = @order.step_commercial.step_estimate.quotes
  end
  
  def update
    if @step.update_attributes(params[:step_estimate])
      flash[:notice] = "L'étape a été modifié avec succès"
    end
    render :action => :edit
  end
end
