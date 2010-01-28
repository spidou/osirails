class DunningsController < ApplicationController
  helper :press_proofs
  
  acts_as_step_controller :step_name => :press_proof_step, :skip_edit_redirection => true

  # GET orders/:order_id/press_proof/press_proofs/:press_proof_id/dunnings/new
  def new
    @dunning = Dunning.new
  end
  
  # POST /orders/:order_id/press_proof/press_proofs/:press_proof_id/dunnings
  def create
    @dunning = Dunning.new(params[:dunning])
    @dunning.creator = current_user
    @dunning.has_dunning = PressProof.find(params[:press_proof_id])
    
    if @dunning.save
      flash[:notice] = "La relance a été créée avec succès"
      redirect_to send(@step.original_step.path)
    else
      render :action => :new
    end
  end
  
  def cancel
    @dunning = Dunning.find(params[:dunning_id])

    if @dunning.cancel(current_user)
      flash[:notice] = "La relance a été annulée avec succès"
    else
      flash[:error]  = "Une erreur est survenue à l'annulation de la relance"
    end
    redirect_to :back
  end
end
