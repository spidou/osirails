class DunningsController < ApplicationController
  helper :press_proofs
  
  acts_as_step_controller :step_name => :press_proof_step, :skip_edit_redirection => true
  
  before_filter :detect_dunnings_owner, :except => [ :cancel ]

  # GET /orders/:order_id/:owner/:owner_id/dunnings/new
  def new
    @dunning = @owner.dunnings.build
    
    error_access_page(412) unless @dunning.can_be_added?
  end
  
  # POST /orders/:order_id/:owner/:owner_id/dunnings
  def create
    @dunning = @owner.dunnings.build(params[:dunning])
    
    if @dunning.can_be_added?
      @dunning.creator = current_user
      
      if @dunning.save
        flash[:notice] = "La relance a été créée avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => :new
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:owner/:owner_id/dunnings/:dunning_id/cancel
  def cancel
    @dunning = Dunning.find(params[:dunning_id])

    if @dunning.cancel(current_user)
      flash[:notice] = "La relance a été annulée avec succès"
    else
      flash[:error]  = "Une erreur est survenue à l'annulation de la relance"
    end
    redirect_to :back
  end
  
  private
    def detect_dunnings_owner
      if params[:owner] and params[:owner_id]
        begin
          @owner_class = params[:owner].constantize
          @owner = @owner_class.send(:find, params[:owner_id].to_i)
        rescue
          error_access_page(400)
        end
      else
        error_access_page(400)
      end
    end
end
