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
    @estimate = Estimate.find(params[:id])
  end

  def show
    @estimate = Estimate.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf { send_data render_pdf, :filename => "estimate.pdf" }
    end
  end

  def create
    @estimate = Estimate.create
    @order.step_commercial.step_estimate.estimates << @estimate
    params[:add_product_references].each do |pr|
      @estimate.estimates_product_references << EstimatesProductReference.create(:product_reference_id => pr.to_i, :quantity => )
    end
    if @order.save and @estimate.save
      flash[:notice] = "Devis créer avec succès"
    else
      flash[:error] = "Erreur lors de la création du devis"
    end
    redirect_to :action => 'index'
  end

  def update
    
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