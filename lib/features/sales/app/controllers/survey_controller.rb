class SurveyController < ApplicationController
  helper :orders, :step
  
  before_filter :check
  
  def show
    if can_edit?(current_user)
      redirect_to :action => "edit"
    end
      

  end
  
  def edit

  end
  
  def update
    ## Save checklist_responses
    unless params[:step_survey][:checklists].nil?
      @checklist_responses.each do |checklist_response|
        checklist_response.update_attributes(params[:step_survey][:checklists]["#{checklist_response.id}"]) unless params[:step_survey][:checklists]["#{checklist_response.id}"][:answer].blank?
      end
    end
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_survey][:remark][:text], :user_id => current_user.id) unless params[:step_survey][:remark][:text].blank?
    
    ## Save Documents
    if params[:new_document_number]["value"].to_i > 0
      documents = params[:step_survey][:documents].dup
      @document_objects = Document.create_all(documents, @step)
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
          @step.documents << document
          document.create_thumbnails
          document.create_preview_format
        end
      end
        
      @step.remarks << @remark unless @remark.nil?
      #      raise params.inspect
      if params[:commit] == "Cloturer"
        @step.terminated!
        redirect_to :action => 'show'
      else
        flash[:notice] = "Dossier modifi&eacute avec succ&egrave;s"
        redirect_to :action => 'edit'
      end
      
    else
      @documents  = @step.documents
      @checklist_responses = @step.checklist_responses
      @new_document_number = params[:new_document_number]["value"]
      flash[:error] = "Une erreur est survenue lors de la sauvegarde du dossier"
      render :action => 'edit'
    end
  end
  
  protected
  
  def check
    @order = Order.find(params[:order_id])
    OrderLog.set(@order, current_user, params) # Manage logs
    @current_order_step = @order.step.first_parent.name[5..-1]
    @step = @order.step_commercial.step_survey
    @checklist_responses = @step.checklist_responses
    @documents = @step.documents
    @remarks = @step.remarks
  end
end