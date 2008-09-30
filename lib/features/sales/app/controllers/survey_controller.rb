class SurveyController < ApplicationController
  helper :documents, :orders, :step
  
  def edit
    ## Objects use to test permission
    @document_controller =Menu.find_by_name('documents')
    
    @order = Order.find(params[:order_id])
    @step_survey = @order.step_commercial.step_survey
    @checklist_responses = @step_survey.checklist_responses
    @documents = @step_survey.documents
    @remarks = @step_survey.remarks
  end
  
  def update
    ## Objects use to test permission
    @document_controller =Menu.find_by_name('documents')
    
    @order = Order.find(params[:order_id])
    @step_commercial = StepCommercial.find_by_order_id(@order.id)
    @step_survey = StepSurvey.find_by_step_commercial_id(@step_commercial.id)
    @checklist_responses = @step_survey.checklist_responses
    @remarks = @step_survey.remarks
    
    ## Save checklist_responses
    unless params[:step_survey][:checklists].nil?
      @checklist_responses.each do |checklist_response|
        checklist_response.update_attributes(params[:step_survey][:checklists]["#{checklist_response.id}"])
      end
    end
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_survey][:remark][:text], :user_id => current_user.id) unless params[:step_survey][:remark][:text].blank?
    
    ## Save Documents
    if params[:new_document_number]["value"].to_i > 0
      documents = params[:step_survey][:documents].dup
      @document_objects = Document.create_all(documents, @step_survey)
    end
    document_params_index = 0
    params[:new_document_number]["value"].to_i.times do |i|
      params[:step_survey][:documents]["#{document_params_index += 1}"] = params[:step_survey][:documents]["#{i + 1}"] unless params[:step_survey][:documents]["#{i + 1}"][:valid] == "false"
    end
    
    ## Test if all documents enable are valid
    unless @document_objects.nil?
      @document_objects.size.times do |i|
        @error = true unless @document_objects[i].valid?
      end
      ## Reaffect document number
      params[:new_document_number]["value"]  = @document_objects.size
    end
    
    unless @error
      if params[:new_document_number]["value"].to_i > 0
        @document_objects.each do |document|
          document.save
          @step_survey.documents << document
          document.create_thumbnails
        end
      end
        
      @step_survey.remarks << @remark unless @remark.nil?
      #      raise params.inspect
      if params[:commit] == "Cloturer"
        @step_survey.status = "terminated"
        @step_survey.save
        redirect_to :action => 'show'
      else
        flash[:notice] = "Dossier modifi&eacute avec succ&egrave;s"
        redirect_to :action => 'edit'
      end
      
    else
      @documents  = @step_survey.documents
      @new_document_number = params[:new_document_number]["value"]
      flash[:error] = "Une erreur est survenue lors de la sauvegarde du dossier"
      render :action => 'edit'
    end
  end
end