module SurveyInterventionsHelper
  
  def display_survey_interventions(survey_step)
    collection = survey_step.survey_interventions.select{ |s| !s.new_record? }
    html = '<div id="survey_interventions">'
    unless collection.empty?
      html << render(:partial => 'survey_interventions/survey_intervention', :collection => collection)
    else
      html << content_tag(:p, "Aucune intervention n'a été trouvé")
    end
    html << render_new_survey_interventions_list(survey_step)
    html << '</div>'
  end
  
  def render_new_survey_interventions_list(survey_step)
    collection = survey_step.survey_interventions.select(&:new_record?)
    collection_with_errors = collection.select{|s|!s.errors.empty?}
    html =  "<div class=\"new_records\" id=\"new_survey_interventions\" #{"style=\"display:none\"" if collection_with_errors.empty?}>"# if collection.empty?}>"
    html << render(:partial => 'survey_interventions/survey_intervention', :collection => collection)
    html << "</div>"
  end
  
  def display_survey_intervention_add_button
    content_tag(:p, link_to_function "Nouvelle intervention", :id => :new_survey_interventions_button do |page|
      page['new_survey_interventions'].show
      page['new_survey_interventions'].down('.survey_intervention').highlight.down('.should_create').value = 1
      page['new_survey_interventions_button'].hide
    end )
  end
  
  def display_survey_intervention_edit_button(survey_intervention)
    link_to_function "Modifier", "mark_resource_for_update(this, {afterFinish: function(){ initialize_autoresize_text_areas() }})" if is_form_view?
  end
  
  def display_survey_intervention_delete_button(survey_intervention)
    link_to_function "Supprimer", "mark_resource_for_destroy(this)" if is_form_view?
  end
  
  def display_survey_intervention_close_form_button(survey_intervention)
    if survey_intervention.new_record?
      link_to_function "Annuler la création de l'intervention" do |page|
        page['new_survey_interventions'].hide
        page['new_survey_interventions'].down('.survey_intervention').down('.should_create').value = 0
        page['new_survey_interventions_button'].show
      end
    else is_form_view?
      link_to_function "Annuler la modification de l'intervention", "mark_resource_for_dont_update(this)"
    end
  end
  
end
