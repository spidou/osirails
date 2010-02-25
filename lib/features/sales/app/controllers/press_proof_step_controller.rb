class PressProofStepController < ApplicationController
  helper :press_proofs, :dunnings, :quotes
  
  acts_as_step_controller

  def show
    @all_press_proofs = []
    @all_press_proofs = @order.products.collect(&:press_proofs).flatten
  end
  
  def edit
    @all_press_proofs = []
    @all_press_proofs = @order.products.collect(&:press_proofs).flatten
  end
  
  def update
    # TODO
  end
  
end
