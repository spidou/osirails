class SurveyStepController < ApplicationController
  helper :documents
  
  acts_as_step_controller
  
  def update
    if @step.update_attributes(params[:survey_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
    end
    render :action => :edit
  end
  
end
