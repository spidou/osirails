class ProductionStepController < ApplicationController
  acts_as_step_controller
  helper :production_steps
  
  def index
  end
  
  def show  
    @order
  end
  
  def edit
    @order
  end
  
  def update
    @production_step = @order.pre_invoicing_step.production_step
    if (@production_step.update_attributes(params[:production_step]))
      flash[:notice] = "production modifié avec succès"
      redirect_to order_pre_invoicing_step_production_step_path(@order)
    else
      render :action => :edit
    end 
  end
  
end
