class SurveyController < ApplicationController

   helper :documents
  
  def edit
    @order = Order.find(params[:order_id])
    @survey = @order.step_commercial.step_survey
    @checklist_responses = @survey.checklist_responses
    @remarks = @survey.remarks
  end
  
   def update
    #    raise params.inspect
    @order = Order.find(params[:id])
    @step = Step.find_by_name("survey")
    @order_step = OrdersSteps.find_by_order_id_and_step_id(@order.id, @step.id)
    @checklist_responses = @order_step.checklist_responses
    
    ## Save checklist_responses
    @checklist_responses.each do |checklist_response|
      checklist_response.update_attributes(params[:order][:survey][:checklists]["#{checklist_response.id}"])
    end
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:order][:survey][:remark][:text])
    
    
    ## Save Documents
    if params[:new_document_number]["value"].to_i > 0
      documents = params[:survey][:documents].dup
      @document_objects = Document.create_all(documents, @step)
    end
    document_params_index = 0
    params[:new_document_number]["value"].to_i.times do |i|
      params[:survey][:documents]["#{document_params_index += 1}"] = params[:survey][:documents]["#{i + 1}"] unless params[:survey][:documents]["#{i + 1}"][:valid] == "false"
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
          @step.documents << document
          document.create_thumbnails
        end
      end
        
      @order_step.remarks << @remark
      flash[:notice] = "Dossier modifi&eacute avec succ&egrave;s"
      redirect_to :action => 'edit'
    else
      @documents  = @step.documents
      @new_document_number = params[:new_document_number]["value"]
      flash[:error] = "Une erreur est survenue lors de la sauvegarde du dossier"
      render :action => 'edit'
    end
  end
end