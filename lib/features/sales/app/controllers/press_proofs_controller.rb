class PressProofsController < ApplicationController
  helper :orders, :graphic_items
  
  acts_as_step_controller :step_name => :press_proof_step, :skip_edit_redirection => true
  
  # GET /orders/:order_id/:step/press_proofs
  def index
    # TODO
  end
  
  # GET /orders/:order_id/:step/press_proofs/:id
  def show
    @press_proof = PressProof.find params[:id]
  end
  
  # GET /orders/:order_id/:step/press_proofs/new
  def new
    @press_proof = PressProof.new
    @mockups = @order.mockups
  end
  
  # POST /orders/:order_id/:step/press_proofs
  def create
    @mockups = @order.mockups
    @press_proof = PressProof.new(params[:press_proof])
    @press_proof.order   = @order
    @press_proof.creator = current_user
    
    if @press_proof.save
      flash[:notice] = "Le Bon à Tirer a été créé avec succès"
      redirect_to send(@step.original_step.path)
    else
      render :action => :new
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id
  def edit
      @press_proof = PressProof.find params[:id]
      @mockups = @order.mockups
      error_access_page(403) unless @press_proof.can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id
  def update
    @press_proof = PressProof.find params[:id]
    @mockups = @order.mockups
    
    if @press_proof.update_attributes params[:press_proof]
      flash[:notice] = "Le Bon à Tirer a été modifié avec succès"
      redirect_to send(@step.original_step.path)
    else
      render :action => :edit
    end
  end
  
  # DELETE /orders/:order_id/:step/press_proofs/:id
  def destroy
    @press_proof = PressProof.find(params[:id])
    if @press_proof.can_be_destroyed?
      flash[:error] = "Une erreur est survenue à la suppression du Bon à Tirer" unless @press_proof.destroy
      redirect_to send(@step.original_step.path)
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/cancel
  def cancel
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof.can_be_cancelled?
     flash[:error] = "Une erreur est survenue à la désactivation du Bon à Tirer" unless @press_proof.cancel
     redirect_to send(@step.original_step.path)
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/confirm
  def confirm
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof.can_be_confirmed?
     flash[:error] = "Une erreur est survenue à la validation du Bon à Tirer" unless @press_proof.confirm
     redirect_to send(@step.original_step.path)
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/send_form
  def send_form
    error_access_page(403) unless (@press_proof = PressProof.find(params[:press_proof_id])).can_be_sended?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/send_to_customer
  def send_to_customer
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof.can_be_sended?
      if @press_proof.send_to_customer(params[:press_proof])
       flash[:notice] = "Le Bon à tirer a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :send_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/sign_form
  def sign_form
    error_access_page(403) unless (@press_proof = PressProof.find(params[:press_proof_id])).can_be_signed?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/sign
  def sign
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof.can_be_signed?
      if  @press_proof.sign(params[:press_proof])
       flash[:notice] = "Le Bon à tirer a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :sign_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/revoke_form
  def revoke_form
    error_access_page(403) unless (@press_proof = PressProof.find(params[:press_proof_id])).can_be_revoked?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/revoke
  def revoke
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof.can_be_revoked?
      params[:press_proof][:revoked_on]    = Date.today
      params[:press_proof][:revoked_by_id] = current_user.id
      
      if @press_proof.revoke(params[:press_proof])
       flash[:notice] = "Le Bon à tirer a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :revoke_form
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/signed_press_proof
  def signed_press_proof
    @press_proof = PressProof.find(params[:press_proof_id])
    if @press_proof and @press_proof.signed?
      url = @press_proof.signed_press_proof.path
      url = File.exists?(url) ? url : @press_proof.signed_press_proof
      
      send_data File.read(url), :filename => "#{@press_proof.id}.pdf", :type => @quote.press_proof_content_type, :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  def add_mockup
    graphic_item_version = GraphicItemVersion.find(params[:mockup_version_id])
    render :update do |page|
      page.insert_html :bottom, "droppable_div", :partial => 'press_proofs/selected_graphic_item_version',
                                                 :object => graphic_item_version,
                                                 :locals => {:without_action => true}
    end
  end
  
end
