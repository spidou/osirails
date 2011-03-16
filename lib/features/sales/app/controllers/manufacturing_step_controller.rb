class ManufacturingStepController < ApplicationController
  helper :delivery_notes
  
  acts_as_step_controller
  
  before_filter :find_manufacturing_step
  
  def show  
  end
  
  def edit
    @manufacturing_step.build_manufacturing_progresses_from_end_products
  end
  
  def update
    if (@manufacturing_step.update_attributes(params[:manufacturing_step]))
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
      redirect_to order_production_step_manufacturing_step_path(@order)
    else
      render :action => :edit
    end
  end
  
  private
    def find_manufacturing_step
      @manufacturing_step = @order.production_step.manufacturing_step
    end
end
