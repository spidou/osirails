class PressProofStepController < ApplicationController
  helper :press_proofs, :dunnings, :quotes, :graphic_items
  
  acts_as_step_controller

  def show
    @all_press_proofs = []
    @all_press_proofs = @order.end_products.collect(&:press_proofs).flatten
  end
  
  def edit
    @all_press_proofs = []
    @all_press_proofs = @order.end_products.collect(&:press_proofs).flatten
  end
  
  def update
    if @step.update_attributes(params[:press_proof_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
      redirect_to :action => :edit
    else
      render :action => :edit
    end
  end
  
end
