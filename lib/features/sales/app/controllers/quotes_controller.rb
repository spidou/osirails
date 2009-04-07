class QuotesController < ApplicationController
  helper :orders

  def index
    @order = Order.find(params[:order_id])
    @quotes = @order.step_commercial.step_estimate.quotes
    redirect_to new_order_step_estimate_quote_path if @quotes.empty?
  end

  def new
    @order = Order.find(params[:order_id])
    @quote = Quote.new
  end

  def show
    @quote = Quote.find(params[:id])
    pdf = render_pdf
    if pdf
      send_data pdf, :filename => "devis_#{@quote.id}.pdf"
    else
      error_access_page(500)
    end
  end
  
  def edit
    @quote = Quote.find(params[:id])
  end

  def create
    @step.in_progress! if @step.unstarted?
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
    
    @step.remarks << @remark unless @remark.nil?
    
    @quote = Quote.create(params[:quote])
    @order.step_commercial.step_estimate.quotes << @quote
    params[:product_references].each do |pr|
      @quote.product_references << QuotesProductReference.create(pr)
    end unless params[:product_references].nil?
    if @order.save and @quote.save
      flash[:notice] = "Devis créer avec succès"
      redirect_to :action => 'index'
    else
      flash[:error] = "Erreur lors de la création du devis"
      redirect_to :action => 'new'
    end
  end


  def update
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
    @step.remarks << @remark unless @remark.nil?

    @quote = Quote.find(params[:id])

    params[:delete_product_reference].each do |to_delete|
      next if to_delete.blank?
      to_delete_object = QuotesProductReference.find(to_delete)
      to_delete_object.destroy if @quote.product_references.include?(to_delete_object)
    end unless params[:delete_product_reference].nil?

    if params[:product_references].nil?
      @quote.product_references.destroy_all
    else
      params[:product_references].each do |pr|
        if pr[:id]
          if @quote.product_references.collect { |e| e.id }.include?(pr[:id].to_i)
            product_ref = QuotesProductReference.find(pr[:id])
            product_ref.update_attributes(pr)
          end
        else
          @quote.product_references << QuotesProductReference.create(pr)
        end
      end 
    end
    
    if @quote.save and @quote.update_attributes(params[:quote])
      if params[:commit] == 'Cloturer'
        @step.terminated!
        flash[:notice] = "Devis cloturer avec succès"
      else
        flash[:notice] = "Devis mis à jour avec succès"
      end
    else
      flash[:error] = "Erreur lors de la mise à jour du devis"
    end
    render :action => 'edit'
  end
end
