class DeliveryNotesController < ApplicationController
  helper :orders, :contacts
  
  after_filter :add_error_in_step_if_delivery_note_has_errors, :only => [ :create, :update ]
  
  acts_as_step_controller :step_name => :delivery_step, :skip_edit_redirection => true
  
  #TODO VERIFY THAT DUPLICATED METHOD
  def show
    if DeliveryNote.can_view?(current_user)
      @delivery_note = DeliveryNote.find(params[:id])
      
      respond_to do |format|
        format.pdf {
          pdf = render_pdf
          if pdf
            send_data pdf, :filename => "bon_livraison_#{@delivery_note.id}.pdf", :disposition => 'attachment'
          else
            error_access_page(500)
          end
        }
        format.html { }
      end
    else
      error_access_page(403)
    end
  end
  
  #TODO VERIFY THAT DUPLICATED METHOD
  def new
    if DeliveryNote.can_add?(current_user)
      if @signed_quote = @order.signed_quote
        @delivery_note = @order.pre_invoicing_step.delivery_step.delivery_notes.build
        @delivery_note.contacts << @order.contacts.last unless @order.contacts.empty?
      else
        flash[:error] = "Il est nécessaire d'avoir un devis <strong>signé</strong> pour créer un bon de livraison"
        redirect_to send(@step.original_step.path)
      end
    else
      error_access_page(403)
    end
  end
  
  #TODO VERIFY THAT DUPLICATED METHOD
  def create
    if DeliveryNote.can_add?(current_user)
      @delivery_note = @order.pre_invoicing_step.delivery_step.delivery_notes.build(params[:delivery_note])
      @delivery_note.creator = current_user
      if @delivery_note.save
        flash[:notice] = "Le bon de livraison a été ajouté avec succès"
        redirect_to send(@step.original_step.path)
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end
  
  #TODO VERIFY THAT DUPLICATED METHOD
  def edit
    if DeliveryNote.can_edit?(current_user)
      @delivery_note = DeliveryNote.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  def update
    if DeliveryNote.can_edit?(current_user)
      @delivery_note = DeliveryNote.find(params[:id])
      
      if @delivery_note.update_attributes(params[:delivery_note])
        flash[:notice] = 'Le bon de livraison a été modifié avec succès'
        redirect_to order_delivery_step_delivery_note_path(@order, @delivery_note)
      else
        render :controller => 'delivery_notes', :action => 'edit'
      end
    else
      error_access_page(422)
    end
  end
  
  private
    #TODO VERIFY THAT DUPLICATED METHOD
    # if delivery_note has errors, the delivery step has also an error to prevent updating of the step status
    def add_error_in_step_if_delivery_note_has_errors
      unless @delivery_note.errors.empty?
        @step.errors.add_to_base("Le bon de livraison n'est pas valide")
      end
    end
  
end
