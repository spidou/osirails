class PressProofStepController < ApplicationController
  helper :press_proofs, :dunnings, :quotes, :graphic_items
  
  acts_as_step_controller
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]

  def show
    @all_press_proofs = []
    @all_press_proofs = @order.end_products.collect(&:press_proofs).flatten
  end
  
  def edit
    @all_press_proofs = []
    @all_press_proofs = @order.end_products.collect(&:press_proofs).flatten
  end
  
  def update
    # TODO
  end
  
end
