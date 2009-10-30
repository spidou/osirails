class SurveyStepController < ApplicationController
  helper :survey_interventions, :contacts, :products, :checklists, :documents, :subcontractor_requests
  
  before_filter :hack_params_for_product_attributes, :only => :update
  
  acts_as_step_controller
  
  def new
    respond_to do |format|
      format.js { render :partial => 'survey_step/product',
                         :object  => @step.order.products.build(:product_reference_id => params[:product_reference_id]),
                         :layout  => false }
    end
  end
  
  def edit
    @step.survey_interventions.build(:start_date => Time.now.to_s(:db), :internal_actor_id => ( current_user.employee ? current_user.employee.id : nil ))
  end
  
  def update
    if @step.update_attributes(params[:survey_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
      redirect_to send(@step.original_step.path)
    else
      render :action => :edit
    end
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_product_attributes # checklist_responses, documents
      if params[:survey_step][:product_attributes] and params[:product]
        params[:survey_step][:product_attributes].each do |product_attributes|
          product_attributes.merge!(params[:product][product_attributes[:id]]) if params[:product][product_attributes[:id]]
        end
        params.delete(:product)
      end
    end
    
end
