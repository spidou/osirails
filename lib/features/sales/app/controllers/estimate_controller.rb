class EstimateController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check, :except => [:index]
  
  def show
    
  end
  
  def edit
    ## Objects use to test permission
    @document_controller =Menu.find_by_name('documents')
    
    @order = Order.find(params[:order_id])
    @step_estimate = @order.step_commercial.step_estimate
    @checklist_responses = @step_estimate.checklist_responses
    @documents = @step_estimate.documents
    @remarks = @step_estimate.remarks
  end
  
  def update
    ## Objects use to test permission
    @document_controller =Menu.find_by_name('documents')
    
    @order = Order.find(params[:order_id])
    @step_estimate = @order.step_commercial.step_estimate
    @checklist_responses = @step_estimate.checklist_responses
    @documents = @step_estimate.documents
    
    ## Save checklist_responses
    @checklist_responses.each do |checklist_response|
      checklist_response.update_attributes(params[:step_estimate][:checklists]["#{checklist_response.id}"])
    end
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
    
    ## Save Documents
    if params[:new_document_number]["value"].to_i > 0
      documents = params[:step_estimate][:documents].dup
      @document_objects = Document.create_all(documents, @step_estimate)
    end
    document_params_index = 0
    params[:new_document_number]["value"].to_i.times do |i|
      params[:step_estimate][:documents]["#{document_params_index += 1}"] = params[:step_estimate][:documents]["#{i + 1}"] unless params[:step_estimate][:documents]["#{i + 1}"][:valid] == "false"
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
      ## Save all documents
      if params[:new_document_number]["value"].to_i > 0
        @document_objects.each do |document|
          document.save
          @step_estimate.documents << document
          document.create_thumbnails
        end
      end
      
      ## Save remark
      @step_estimate.remarks << @remark unless @remark.nil?
      
      if params[:commit] == "Cloturer"
        @step_estimate.status = "terminated"
        @step_estimate.save
        redirect_to :action => 'show'
      else
        flash[:notice] = "Dossier modifi&eacute avec succ&egrave;s"
        redirect_to :action => 'edit'
      end
      
    else
      @documents  = @step_estimate.documents
      @new_document_number = params[:new_document_number]["value"]
      flash[:error] = "Une erreur est survenue lors de la sauvegarde du dossier"
      render :action => 'edit'
    end
    
  end
  
  protected
  
  def check
    @order = Order.find(params[:order_id])
  end
end