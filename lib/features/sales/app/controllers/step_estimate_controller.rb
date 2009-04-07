class StepEstimateController < ApplicationController
    
  acts_as_step_controller

  # def index
  #   @estimates = @order.step_commercial.step_estimate.estimates
  #   redirect_to new_order_estimate_path if @estimates.empty?
  # end

  # def new
  #   @estimate = Estimate.new
  # end

  def show
    @estimate = Estimate.find(params[:id])
    pdf = render_pdf
    if pdf
      send_data pdf, :filename => "devis_#{@estimate.id}.pdf"
    else
      error_access_page(500)
    end
  end
  
  def edit
    # @estimate = Estimate.find(params[:id])
  end

  # def create
  #   @step.in_progress! if @step.unstarted?
  #   
  #   ## Save Remarks
  #   @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
  #   
  #   @step.remarks << @remark unless @remark.nil?
  #   
  #   @estimate = Estimate.create(params[:estimate])
  #   @order.step_commercial.step_estimate.estimates << @estimate
  #   params[:product_references].each do |pr|
  #     @estimate.estimates_product_references << EstimatesProductReference.create(pr)
  #   end unless params[:product_references].nil?
  #   if @order.save and @estimate.save
  #     flash[:notice] = "Devis créer avec succès"
  #     redirect_to :action => 'index'
  #   else
  #     flash[:error] = "Erreur lors de la création du devis"
  #     redirect_to :action => 'new'
  #   end
  # end
  
  def update
    if @step.update_attributes(params[:step_estimate])
      flash[:notice] = "L'étape a été modifié avec succès"
    end
    render :action => :edit
  end


#  def update
#    ## Save Remarks
#    @remark = Remark.new(:text => params[:step_estimate][:remark][:text], :user_id => current_user.id) unless params[:step_estimate][:remark][:text].blank?
#    @step.remarks << @remark unless @remark.nil?
#
#    @estimate = Estimate.find(params[:id])
#
#    params[:delete_product_reference].each do |to_delete|
#      next if to_delete.blank?
#      to_delete_object = EstimatesProductReference.find(to_delete)
#      to_delete_object.destroy if @estimate.estimates_product_references.include?(to_delete_object)
#    end unless params[:delete_product_reference].nil?
#
#    if params[:product_references].nil?
#      @estimate.estimates_product_references.destroy_all
#    else
#      params[:product_references].each do |pr|
#        if pr[:id]
#          if @estimate.estimates_product_references.collect { |e| e.id }.include?(pr[:id].to_i)
#            product_ref = EstimatesProductReference.find(pr[:id])
#            product_ref.update_attributes(pr)
#          end
#        else
#          @estimate.estimates_product_references << EstimatesProductReference.create(pr)
#        end
#      end 
#    end
#    
#    if @estimate.save and @estimate.update_attributes(params[:estimate])
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
