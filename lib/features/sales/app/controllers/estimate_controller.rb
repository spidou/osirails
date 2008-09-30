class EstimateController < ApplicationController
  helper 'orders'
  
  attr_accessor :current_order_step
  before_filter :check_order
  
  def index
    @estimates = @order.step_commercial.step_estimate.estimates
  end
  
  def new
    @estimate = Estimate.new
  end
  
  def edit
    @estimate = Estimate.find(params[:id])
  end
  
  def show
    #require 'htmldoc'
    #data = render_to_string(:action => 'show.pdf.erb', :layout => false)
    #pdf = PDF::HTMLDoc.new
    #pdf.set_option :bodycolor, :white
    #pdf.set_option :toc, false
    #pdf.set_option :charset, 'utf-8'
    #pdf.set_option :portrait, true
    #pdf.set_option :links, false
    #pdf.set_option :webpage, true
    #pdf.set_option :left, '1cm'
    #pdf.set_option :right, '1cm'
    #pdf << data
    #document = pdf.generate
    #
    #send_data document, :filename => "estimate.pdf"
  end
  
  def create
    if @estimate = Estimate.create
      params[:add_product_references].each do |pr|
        @estimate.estimates_product_references << EstimatesProductReference.create(:product_reference_id => pr.to_i)
        flash[:notice] = "Devis créer avec succès"
      end
    else
      flash[:error] = "Erreur lors de la création du devis"
    end
    redirect_to :action => 'index'
  end
  
  def update
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
  
  def check_order
    @order = Order.find(params[:order_id])
    @customer = @order.customer
  end
end