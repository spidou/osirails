class GraphicConceptionStepController < ApplicationController
  helper :documents, :press_proofs
  
  acts_as_step_controller :step_name => :graphic_conception_step
  
  def show
  end
  
  def edit
  end
  
  def update
    if @step.update_attributes(params[:graphic_conception_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
    end
    render :action => :edit
  end
  
end
