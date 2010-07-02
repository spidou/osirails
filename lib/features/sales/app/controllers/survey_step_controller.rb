class SurveyStepController < ApplicationController
  helper :survey_interventions, :contacts, :products, :checklists, :documents, :subcontractor_requests, :quotes, :press_proofs, :graphic_items, :numbers
  
  before_filter :hack_params_for_nested_attributes, :only => :update
  
  acts_as_step_controller
  
  #OPTIMIZE move that method to a better place
  def new
    respond_to do |format|
      format.js { render :partial => 'survey_step/product',
                         :object  => @step.order.products.build(:product_reference_id => params[:product_reference_id]),
                         :layout  => false }
    end
  end
  
  def edit
    @contacts_owners = @step.order.customer.head_office_and_establishments
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
    def hack_params_for_nested_attributes # checklist_responses, documents
      if params[:survey_step][:product_attributes] and params[:product]
        params[:survey_step][:product_attributes].each do |product_attributes|
          product_attributes.merge!(params[:product][product_attributes[:id]]) if params[:product][product_attributes[:id]]
        end
        params.delete(:product)
      end
      
      
#      if params[:survey_step][:survey_intervention_attributes] and params[:survey_intervention]
#        params[:survey_step][:survey_intervention_attributes].each_with_index do |survey_intervention_attributes, index|
#          next if params[:survey_intervention][:survey_intervention_contact_attributes][index].nil? # mean that the survey intervention do not create a new contact but choose an existing one
#          survey_intervention_attributes[:survey_intervention_contact_attributes] = params[:survey_intervention][:survey_intervention_contact_attributes][index]
#          if params[:contact]
#            number_attributes = params[:contact][:number_attributes].select {|n| 
#              n[:has_number_id] == survey_intervention_attributes[:survey_intervention_contact_attributes][:id]
#            }
#            survey_intervention_attributes[:survey_intervention_contact_attributes][:number_attributes] = clean_params(number_attributes, :has_number_id)
#          end
#          remove_fake_ids(survey_intervention_attributes[:survey_intervention_contact_attributes])
#        end
#        params.delete(:survey_intervention)
#        params.delete(:contact)
#      end
      
    end
    
end
