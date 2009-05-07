class QuotesController < ApplicationController
  helper :orders
  
  acts_as_step_controller :step_name => :step_estimate

  def index
    if Quote.can_list?(current_user)
      @quotes = @order.step_commercial.step_estimate.quotes
      redirect_to new_order_step_estimate_quote_path if @quotes.empty?
    else
      error_access_page(403)
    end
  end
  
  def show
    if Quote.can_view?(current_user)
      @quote = Quote.find(params[:id])
      pdf = render_pdf
      if pdf
        send_data pdf, :filename => "devis_#{@quote.id}.pdf"
      else
        error_access_page(500)
      end
    else
      error_access_page(403)
    end
  end
  
  def new
    if Quote.can_add?(current_user)
      @quote = @order.step_commercial.step_estimate.quotes.build
    else
      error_access_page(403)
    end
  end
  
  def create
    if Quote.can_add?(current_user)
      @quote = @order.step_commercial.step_estimate.quotes.build(params[:quote])
      if @quote.save
        flash[:notice] = "Le devis a été ajout&eacute; avec succ&egrave;s"
        redirect_to order_step_estimate_path(@order)
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end

#  def create
#    @step.in_progress! if @step.unstarted?
#    
#    ## Save Remarks
#    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
#    
#    @step.remarks << @remark unless @remark.nil?
#    
#    @quote = Quote.create(params[:quote])
#    @order.step_commercial.step_estimate.quotes << @quote
#    params[:product_references].each do |pr|
#      @quote.product_references << QuotesProductReference.create(pr)
#    end unless params[:product_references].nil?
#    if @order.save and @quote.save
#      flash[:notice] = "Devis créer avec succès"
#      redirect_to :action => 'index'
#    else
#      flash[:error] = "Erreur lors de la création du devis"
#      redirect_to :action => 'new'
#    end
#  end
  
  def edit
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:id])
    end
  end
  
  def update
    if Quote.can_edit?(current_user)
      @quote = Quote.find(params[:id])
      
      if @quote.update_attributes(params[:quote])
      flash[:notice] = 'Le devis a été modifié avec succès'
      render :nothing => true
    else
      render :action => 'edit'
    end
    end
  end

#  def update
#    ## Save Remarks
#    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
#    @step.remarks << @remark unless @remark.nil?
#
#    @quote = Quote.find(params[:id])
#
#    params[:delete_product_reference].each do |to_delete|
#      next if to_delete.blank?
#      to_delete_object = QuotesProductReference.find(to_delete)
#      to_delete_object.destroy if @quote.product_references.include?(to_delete_object)
#    end unless params[:delete_product_reference].nil?
#
#    if params[:product_references].nil?
#      @quote.product_references.destroy_all
#    else
#      params[:product_references].each do |pr|
#        if pr[:id]
#          if @quote.product_references.collect { |e| e.id }.include?(pr[:id].to_i)
#            product_ref = QuotesProductReference.find(pr[:id])
#            product_ref.update_attributes(pr)
#          end
#        else
#          @quote.product_references << QuotesProductReference.create(pr)
#        end
#      end 
#    end
#    
#    if @quote.save and @quote.update_attributes(params[:quote])
#      if params[:commit] == 'Cloturer'
#        @step.terminated!
#        flash[:notice] = "Devis cloturer avec succès"
#      else
#        flash[:notice] = "Devis mis à jour avec succès"
#      end
#    else
#      flash[:error] = "Erreur lors de la mise à jour du devis"
#    end
#    render :action => 'edit'
#  end
end
