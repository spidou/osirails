class SurveyStepController < ApplicationController
  helper :documents
  
  acts_as_step_controller
  
  def update
    if @step.update_attributes(params[:survey_step])
      flash[:notice] = "L'étape a été modifié avec succès"
    end
    render :action => :edit
  end
  
end
