class DeliveryNotesController < ApplicationController
  helper :orders, :contacts, :delivery_interventions
  
  acts_as_step_controller :step_name => :delivery_step, :skip_edit_redirection => true
  
  before_filter :find_delivery_note
  
  #after_filter :add_error_in_step_if_delivery_note_has_errors, :only => [ :create, :update ]
  
  # GET /orders/:order_id/:step/delivery_notes/:id
  # GET /orders/:order_id/:step/delivery_notes/:id.pdf
  def show
    if @delivery_note.uncomplete? and params[:format] == "pdf"
      error_access_page(404)
      return
    end
    
    respond_to do |format|
      format.xml {
        render :layout => false
      }
      format.pdf {
        pdf_filename = "bon_livraison_#{@delivery_note.reference}"
        render_pdf(pdf_filename, "delivery_notes/show.xml.erb", "public/fo/style/delivery_note.xsl", "assets/pdf/delivery_notes/#{pdf_filename}.pdf")
      }
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/new
  def new
    if @signed_quote = @order.signed_quote
      @delivery_note = @order.delivery_notes.build
      @delivery_note.build_delivery_note_items_from_signed_quote
      @delivery_note.contacts << @order.contacts.last unless @order.contacts.empty?
      @delivery_note.creator = current_user
    else
      error_access_page(412)
    end
  end
  
  # POST /orders/:order_id/:step/delivery_notes/:id
  def create
    @delivery_note = @order.delivery_notes.build
    @delivery_note.attributes = params[:delivery_note]
    @delivery_note.creator = current_user
    if @delivery_note.save
      flash[:notice] = "Le bon de livraison a été ajouté avec succès"
      redirect_to send(@step.original_step.path)
    else
      render :action => 'new'
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:id/edit
  def edit
    error_access_page(412) unless @delivery_note.can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/delivery_notes/:id
  def update
    if @delivery_note.can_be_edited?
      if @delivery_note.update_attributes(params[:delivery_note])
        flash[:notice] = 'Le bon de livraison a été modifié avec succès'
        redirect_to send(@step.original_step.path)
      else
        render :controller => 'delivery_notes', :action => 'edit'
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /orders/:order_id/:step/delivery_notes/:id
  def destroy
    if @delivery_note.can_be_destroyed?
      unless @delivery_note.destroy
        flash[:notice] = 'Une erreur est survenue à la suppression du bon de livraison'
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/confirm
  def confirm
    if @delivery_note.can_be_confirmed?
      unless @delivery_note.confirm
        flash[:error] = "Une erreur est survenue à la validation du bon de livraison"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/schedule_form
  def schedule_form
    if @delivery_note.can_be_scheduled?
      @delivery_intervention = @delivery_note.pending_delivery_intervention || @delivery_note.delivery_interventions.build
      @delivery_intervention.scheduled_delivery_at ||= Time.now.beginning_of_hour unless @delivery_intervention.outdated?
    else
      error_access_page(412)
    end
  end
  
  # PUT /orders/:order_id/:step/delivery_notes/:delivery_note_id/schedule
  def schedule
    if @delivery_note.can_be_scheduled?
      @delivery_intervention = @delivery_note.pending_delivery_intervention || @delivery_note.delivery_interventions.build
      @delivery_intervention.attributes = params[:delivery_intervention]
      new = @delivery_intervention.new_record?
      
      if @delivery_intervention.save
        flash_message = new ? "Une nouvelle intervention a été planifiée avec succès" : "L'intervention a été modifiée avec succès"
        flash[:notice] = flash_message
        
        redirect_to send(@step.original_step.path)
      else
        render :action => :schedule_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/realize_form
  def realize_form
    @delivery_intervention = @delivery_note.pending_delivery_intervention
    
    error_access_page(412) unless @delivery_note.can_be_realized? and @delivery_intervention
    
    @delivery_intervention.delivered = true
    
    @delivery_intervention.delivery_at                    = @delivery_intervention.scheduled_delivery_at
    @delivery_intervention.internal_actor_id              = @delivery_intervention.scheduled_internal_actor_id
    @delivery_intervention.delivery_subcontractor_id      = @delivery_intervention.scheduled_delivery_subcontractor_id
    @delivery_intervention.installation_subcontractor_id  = @delivery_intervention.scheduled_installation_subcontractor_id
  end
  
  # PUT /orders/:order_id/:step/delivery_notes/:delivery_note_id/schedule
  def realize
    @return_uri = params[:return_uri] # permit to be redirected to intervention creation (or other uri) when necessary
    @delivery_intervention = @delivery_note.pending_delivery_intervention
    
    if @delivery_note.can_be_realized? and @delivery_intervention
      @delivery_intervention.attributes = params[:delivery_intervention]
      
      if @delivery_intervention.save
        flash[:notice] = "L'intervention a été réalisée avec succès"
        
        redirect_to( @return_uri || send(@step.original_step.path) )
      else
        render :action => :realize_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/sign_form
  def sign_form
    error_access_page(412) unless @delivery_note.can_be_signed?
    @delivery_note.signed_on = @delivery_note.delivered_delivery_intervention.delivery_at
  end
  
  # PUT /orders/:order_id/:step/delivery_notes/:delivery_note_id/sign
  def sign
    if @delivery_note.can_be_signed?
      @delivery_note.attributes = params[:delivery_note]
      if @delivery_note.sign
        flash[:notice] = 'Le bon de livraison a été modifié avec succès'
        
        redirect_to send(@step.original_step.path)
      else
        render :action => :sign_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/cancel
  def cancel
    if @delivery_note.can_be_cancelled?
      unless @delivery_note.cancel
        flash[:error] = "Une erreur est survenue à l'annulation du bon de livraison"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/attachment
  def attachment
    if @delivery_note and @delivery_note.was_signed?
      url = @delivery_note.attachment.path
      ext = File.extname(url)
      
      send_data File.read(url), :filename    => "bon_livraison_signé_#{@delivery_note.id}#{ext}",
                                :type        => @delivery_note.attachment_content_type,
                                :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  private
    ## if delivery_note has errors, the delivery step has also an error to prevent updating of the step status
    #def add_error_in_step_if_delivery_note_has_errors
    #  unless @delivery_note.errors.empty?
    #    @step.errors.add_to_base("Le bon de livraison n'est pas valide")
    #  end
    #end
    
    def find_delivery_note
      if id = params[:id] || params[:delivery_note_id]
        @delivery_note = DeliveryNote.find(id)
        error_access_page(404) unless @order and @order.delivery_notes.include?(@delivery_note)
      end
    end
    
    def render_pdf(pdf_filename, template, xsl_path, pdf_path, is_temporary_pdf=false)
      unless File.exist?(pdf_path)
        area_tree_path = Fop.area_tree_from_xml_and_xsl(render_to_string(:template => template, :layout => false), xsl_path, "public/fo/tmp/#{File.basename(pdf_path,".pdf")}.at")  
        
        total_pages = `xpath -e "count(//page)" #{area_tree_path}`.to_i
        offset_value = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/).last.to_i

        File.delete(area_tree_path)
        
        modified_xsl_path = "public/fo/tmp/modified_invoice_for_#{File.basename(pdf_path,".pdf")}.xsl"
        
        `cp -f #{xsl_path} #{modified_xsl_path}`

        if total_pages == 1
          optimum_offset_value = 560000 # FIXME This value must change if the size of all elements before the table change
        else
          optimum_offset_value = 700000 # This value should normally be constant
        end
        
        if offset_value < optimum_offset_value
          additionnal_offset_value = optimum_offset_value - offset_value
          new_padding = (additionnal_offset_value * 0.0000325) + 0.1
          
          `replace '<xsl:attribute name="padding-top">1mm</xsl:attribute> <!-- COMMENT FOR DYNAMIC RESIZE OF THE EMPTY LINE, DO NOT REMOVE ME AND DO NOT COPY ME -->' '<xsl:attribute name="padding-top">#{new_padding}cm</xsl:attribute>' -- #{modified_xsl_path}`
        end
        
        render :pdf => pdf_filename, :template => template, :xsl => modified_xsl_path, :path => pdf_path, :is_temporary_pdf => is_temporary_pdf
     
        File.delete(modified_xsl_path)
      else
        render :pdf => pdf_filename, :path => pdf_path
      end
    end
  
end
