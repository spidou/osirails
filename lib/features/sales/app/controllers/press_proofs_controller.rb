class PressProofsController < ApplicationController
  helper :orders, :graphic_items, :dunnings
  
  acts_as_step_controller :step_name => :press_proof_step, :skip_edit_redirection => true
  
  skip_before_filter :lookup_step_environment, :only => [:context_menu]
  
  before_filter :find_press_proof
  before_filter :load_order_mockups, :only => [ :new, :create, :edit, :update ]
  
  # GET /orders/:order_id/:step/press_proofs
  def index
    redirect_to send(@step.original_step.path)
  end
  
  # GET /orders/:order_id/:step/press_proofs/:id
  def show
    respond_to do |format|
      format.xml  {
        render :layout => false
      }
      format.pdf  {
        set_cache_buster unless @press_proof.can_be_downloaded? # don't allow browser caching when downloading preview
        
        pdf_path = "assets/sales/press_proofs/generated_pdf/#{@press_proof.can_be_downloaded? ? @press_proof.id : 'tmp_'+generate_random_id}.pdf" # => "1.pdf" or "tmp_W91OA918.pdf"
        pdf_filename = "#{PressProof.human_name.parameterize.to_s}_#{@press_proof.can_be_downloaded? ? @press_proof.reference : 'tmp_'+generate_random_id}" # => "press-proof_REFPRESSPROOF" or "press-proof_tmp_W91OA918"
        render :pdf => pdf_filename, :xml_template => "press_proofs/show.xml.erb", :xsl_template => "press_proofs/show.xsl.erb", :path => pdf_path, :is_temporary_pdf => !@press_proof.can_be_downloaded?
      }
      format.html { }
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/new
  def new
    @press_proof = @order.press_proofs.build
    
    unless @order.all_end_products_have_signed_press_proof?
      @press_proof.internal_actor = current_user.employee
      @press_proof.creator = current_user
    else
      error_access_page(412)
    end
  end
  
  # POST /orders/:order_id/:step/press_proofs
  def create
    @press_proof = @order.press_proofs.build(params[:press_proof])
    @press_proof.creator = current_user
    
    if @press_proof.can_be_created? and !@order.all_end_products_have_signed_press_proof?
      if @press_proof.save
        flash[:notice] = "Le Bon à Tirer (BAT) a été créé avec succès"
        redirect_to order_commercial_step_press_proof_step_press_proof_path(@order, @press_proof)
      else
        render :action => :new
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id
  def edit
    error_access_page(412) unless @press_proof.can_be_edited?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id
  def update
    if @press_proof.can_be_edited?
      if @press_proof.update_attributes(params[:press_proof])
        flash[:notice] = "Le Bon à Tirer (BAT) a été modifié avec succès"
        redirect_to order_commercial_step_press_proof_step_press_proof_path(@order, @press_proof)
      else
        render :action => :edit
      end
    else
      error_access_page(412)
    end
  end
  
  # DELETE /orders/:order_id/:step/press_proofs/:id
  def destroy
    if @press_proof.can_be_destroyed?
      if @press_proof.destroy
        flash[:notice] = "Le Bon à Tirer (BAT) a été supprimé avec succès"
      else
        flash[:error] = "Une erreur est survenue à la suppression du Bon à Tirer (BAT)"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/cancel
  def cancel
    if @press_proof.can_be_cancelled?
      if @press_proof.cancel
        flash[:notice] = "Le Bon à Tirer (BAT) a été annulé avec succès"
      else
        flash[:error] = "Une erreur est survenue à la désactivation du Bon à Tirer (BAT)"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/confirm
  def confirm
    if @press_proof.can_be_confirmed?
      if @press_proof.confirm
        flash[:notice] = "Le Bon à Tirer (BAT) a été validé avec succès"
      else
        flash[:error] = "Une erreur est survenue à la validation du Bon à Tirer (BAT)"
      end
      redirect_to send(@step.original_step.path)
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/send_form
  def send_form
    error_access_page(412) unless @press_proof.can_be_sended?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/send_to_customer
  def send_to_customer
    if @press_proof.can_be_sended?
      if @press_proof.send_to_customer(params[:press_proof])
       flash[:notice] = "Le Bon à tirer (BAT) a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :send_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/sign_form
  def sign_form
    error_access_page(412) unless @press_proof.can_be_signed?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/sign
  def sign
    if @press_proof.can_be_signed?
      if @press_proof.sign(params[:press_proof])
       flash[:notice] = "Le Bon à tirer (BAT) a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :sign_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/revoke_form
  def revoke_form
    error_access_page(412) unless @press_proof.can_be_revoked?
  end
  
  # PUT /orders/:order_id/:step/press_proofs/:press_proof_id/revoke
  def revoke
    if @press_proof.can_be_revoked?
      @press_proof.revoked_by_id = current_user.id
      if @press_proof.revoke(params[:press_proof])
       flash[:notice] = "Le Bon à tirer (BAT) a été modifié avec succés"
       redirect_to send(@step.original_step.path)
      else
        render :action => :revoke_form
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /orders/:order_id/:step/press_proofs/:press_proof_id/signed_press_proof
  def signed_press_proof
    if @press_proof and @press_proof.signed?
      url = @press_proof.signed_press_proof.path
      ext = File.extname(url)
      
      send_data File.read(url), :filename => "BAT" + "_#{@press_proof.reference}_" + "signé" + ext, :type => @press_proof.signed_press_proof_content_type, :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  def add_mockup
    @press_proof ||= PressProof.new
    
    graphic_item_version = GraphicItemVersion.find(params[:mockup_version_id])
    position             = params[:position].to_i
    
    render :update do |page|
      page.insert_html :bottom, "droppable_div", :partial => 'press_proofs/selected_graphic_item_version',
                                                 :object  => graphic_item_version,
                                                 :locals  => { :position    => position,
                                                               :press_proof => @press_proof }
    end
  end
  
  private
    def find_press_proof
      if id = params[:id] || params[:press_proof_id]
        @press_proof = PressProof.find(id)
        error_access_page(404) unless @order and @press_proof.order_id == @order.id
      end
    end
    
    def load_order_mockups
      @mockups = @order.mockups
    end
end
