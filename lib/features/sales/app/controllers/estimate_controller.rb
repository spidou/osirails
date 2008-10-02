class EstimateController < ApplicationController
  helper :orders, :step

  attr_accessor :current_order_step
  before_filter :check_order

  def index
    @estimates = @order.step_commercial.step_estimate.estimates
    redirect_to new_order_estimate_path if @estimates.blank?
  end

  def new
    @estimate = Estimate.new
  end

  def edit
    unless can_edit?(current_user)
      redirect_to :action => 'show'
      return
    end
    
    @estimate = Estimate.find(params[:id])
  end

  def show
    @estimate = Estimate.find(params[:id])
    send_data render_pdf, :filename => "Devis-#{@estimate.id}.pdf"
  end

  def create
    @step.in_progress! if @step.unstarted?
    
    ## Save Remarks
    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
    
    @step.remarks << @remark unless @remark.nil?
    
    @estimate = Estimate.create(params[:estimate])
    @order.step_commercial.step_estimate.estimates << @estimate
    params[:product_references].each do |pr|
      @estimate.estimates_product_references << EstimatesProductReference.create(pr)
    end unless params[:product_references].nil?
    if @order.save and @estimate.save
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

    @estimate = Estimate.find(params[:id])

    params[:delete_product_reference].each do |dpr|
      next if dpr.blank?
      dpr_obj = EstimatesProductReference.find(dpr)
      dpr_obj.destroy if @estimate.estimates_product_references.include?(dpr_obj)
    end unless params[:delete_product_reference].nil?

    if params[:product_references].nil?
      @estimate.estimates_product_references.destroy_all
    else
      params[:product_references].each do |pr|
        if pr[:id]
          if @estimate.estimates_product_references.collect { |e| e.id }.include?(pr[:id].to_i)
            product_ref = EstimatesProductReference.find(pr[:id])
            product_ref.update_attributes(pr)
          end
        else
          @estimate.estimates_product_references << EstimatesProductReference.create(pr)
        end
      end 
    end
    
    if @estimate.save and @estimate.update_attributes(params[:estimate])
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

  protected

  def check_order
    @order = Order.find(params[:order_id])
    @customer = @order.customer
    
    @step = @order.step_commercial.step_estimate
    # @checklist_responses = @step.checklist_responses
    # @documents = @step.documents
    @remarks = @step.remarks
  end
  
  def render_pdf
    require 'htmldoc'
    data = render_to_string(:action => "#{params[:action]}.pdf.erb", :layout => false)
    pdf = PDF::HTMLDoc.new
    pdf.set_option :bodycolor, :white
    pdf.set_option :toc, false
    pdf.set_option :charset, 'utf-8'
    pdf.set_option :portrait, true
    pdf.set_option :links, false
    pdf.set_option :webpage, true
    pdf.set_option :left, '1cm'
    pdf.set_option :right, '1cm'
    pdf << data
    pdf.generate
  end
end