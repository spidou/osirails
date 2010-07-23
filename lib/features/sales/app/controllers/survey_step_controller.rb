class SurveyStepController < ApplicationController
  helper :survey_interventions, :contacts, :end_products, :checklists, :documents, :subcontractor_requests, :quotes, :press_proofs, :graphic_items
  
  before_filter :hack_params_for_end_product_attributes, :only => :update
  
  acts_as_step_controller
  
  #OPTIMIZE move that method to a better place
  def new
    respond_to do |format|
      format.js { render :partial => 'survey_step/end_product',
                         :object  => @step.order.end_products.build(:product_reference_id => params[:product_reference_id]),
                         :layout  => false }
    end
  end
  
  def update
    if @step.update_attributes(params[:survey_step])
      flash[:notice] = "Les modifications ont été enregistrées avec succès"
      redirect_to :action => :edit
    else
      render :action => :edit
    end
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_end_product_attributes # checklist_responses, documents
      if params[:survey_step][:end_product_attributes] and params[:end_product]
        params[:survey_step][:end_product_attributes].each do |end_product_attributes|
          end_product_attributes.merge!(params[:end_product][end_product_attributes[:id]]) if params[:end_product][end_product_attributes[:id]]
        end
        params.delete(:end_product)
      end
    end
    
end
