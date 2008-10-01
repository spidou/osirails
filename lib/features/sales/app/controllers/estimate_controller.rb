class EstimateController < ApplicationController
  helper 'orders'

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
    respond_to do |format|
      format.html { redirect_to :action => 'edit' if can_edit?(current_user) }
      format.pdf { send_data render_pdf, :filename => "Devis-#{@estimate.id}.pdf" }
    end
  end

  def create
    @estimate = Estimate.create(params[:estimate])
    @order.step_commercial.step_estimate.estimates << @estimate
    params[:product_references].each do |pr|
      @estimate.estimates_product_references << EstimatesProductReference.create(pr)
    end
    if @order.save and @estimate.save
      flash[:notice] = "Devis créer avec succès"
    else
      flash[:error] = "Erreur lors de la création du devis"
    end
    redirect_to :action => 'index'
  end

  def update
    @estimate = Estimate.find(params[:id])
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
    
    if @estimate.save and @estimate.update_attributes(params[:estimate])
      flash[:notice] = "Devis mis à jour avec succès"
    else
      flash[:error] = "Erreur lors de la mise à jour du devis"
    end
    redirect_to order_estimate_path(@order, @estimate)
  end

  protected

  def check_order
    @order = Order.find(params[:order_id])
    @customer = @order.customer
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