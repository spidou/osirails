class StepGraphicConceptionController < ApplicationController
  helper :documents, :press_proofs
  
  acts_as_step_controller :step_name => :step_graphic_conception
  
  def show
    respond_to do |format|
      format.html {}
      format.pdf {
        data = render_to_string(:action => "show.pdf.erb", :layout => false)
        pdf = PDF::HTMLDoc.new
        pdf.set_option :bodycolor, 'white'
        pdf.set_option :toc, false
        pdf.set_option :charset, 'utf-8'
        pdf.set_option :portrait, true
        pdf.set_option :links, false
        pdf.set_option :webpage, true
        pdf.set_option :left, '1cm'
        pdf.set_option :right, '1cm'
        pdf.set_option :textcolor, 'black'
        
        pdf << data
        @step.documents.each do |document|
          # document.convert_to_png
          pdf << "<h2 align=\"center\">#{document.name}</h2><br /><div align=\"center\"><img src=\"#{document.attachment.path(:medium)}\" /></div>"
        end
        
        pdf.footer "./."
        
        send_data pdf.generate, :filename => "bon_a_tirer_#{@order.id}.pdf"
      }
    end
  end
  
  def edit
  end
  
  def update
    if @step.update_attributes(params[:step_graphic_conception])
      flash[:notice] = "L'étape a été modifié avec succès"
    end
    render :action => :edit
  end
  
#  def update
#    @order = Order.find(params[:order_id])
#    @step = @order.step_commercial.step_graphic_conception
#    @checklist_responses = @step.checklist_responses
#    @documents = @step.documents
#    @remarks = @step.remarks
#    
#    ## Save checklist_responses
#    unless params[:step_graphic_conception][:checklists].nil?
#      @checklist_responses.each do |checklist_response|
#        checklist_response.update_attributes(params[:step_graphic_conception][:checklists]["#{checklist_response.id}"]) unless params[:step_graphic_conception][:checklists]["#{checklist_response.id}"][:answer].blank?
#      end
#    end
#    
#    ## Save Remarks
#    @remark = Remark.new(:text => params[:step_graphic_conception][:remark][:text], :user_id => current_user.id) unless params[:step_graphic_conception][:remark][:text].blank?
#    
#    ## Save Documents
#    if params[:new_document_number]["value"].to_i > 0
#      documents = params[:step_graphic_conception][:documents].dup
#      @document_objects = Document.create_all(documents, @step)
#    end
#    document_params_index = 0
#    params[:new_document_number]["value"].to_i.times do |i|
#      params[:step_graphic_conception][:documents]["#{document_params_index += 1}"] = params[:step_graphic_conception][:documents]["#{i + 1}"] unless params[:step_graphic_conception][:documents]["#{i + 1}"][:valid] == "false"
#    end
#    
#    ## Test if all documents enable are valid
#    unless @document_objects.nil?
#      @document_objects.size.times do |i|
#        @error = true unless @document_objects[i].valid?
#      end
#      ## Reaffect document number
#      params[:new_document_number]["value"]  = @document_objects.size
#    end
#    
#    unless @error
#      if params[:new_document_number]["value"].to_i > 0
#        @document_objects.each do |document|
#          document.save
#          @step.documents << document
#          document.create_thumbnails
#          document.create_preview_format
#        end
#      end
#      
#      unless params[:press_proofs].nil? or params[:press_proofs].empty?
#        @press_proof = PressProof.create(:status => "in_progress")
#        params[:press_proofs].each {|document_id| @press_proof.documents << Document.find(document_id.split("_")[1])}
#        
#        @step.press_proofs << @press_proof if @press_proof
#      end
#      
#      @step.remarks << @remark unless @remark.nil?
#      
#      if params[:commit] == "Cloturer"
#        @step.terminated!
#        redirect_to :action => 'show'
#      else
#        flash[:notice] = "Dossier modifi&eacute avec succ&egrave;s"
#        redirect_to :action => 'edit'
#      end
#      
#    else
#      @documents  = @step.documents
#      @new_document_number = params[:new_document_number]["value"]
#      flash[:error] = "Une erreur est survenue lors de la sauvegarde du dossier"
#      render :action => 'edit'
#    end
#  end
end
