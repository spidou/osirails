module SubcontractorRequestsHelper
  
  def display_subcontractor_requests(survey_step)
    collection = survey_step.subcontractor_requests.select{ |s| !s.new_record? }
    html = '<div id="subcontractor_requests">'
    unless collection.empty?
      html << render(:partial => 'subcontractor_requests/subcontractor_request', :collection => collection)
    else
      html << content_tag(:p, "Aucun travail de sous-traitance n'a été trouvé")
    end
    html << render_new_subcontractor_requests_list(survey_step)
    html << '</div>'
  end
  
  def render_new_subcontractor_requests_list(survey_step)
    collection = survey_step.subcontractor_requests.select(&:new_record?)
    html =  "<div class=\"new_records\" id=\"new_subcontractor_requests\">"
    html << render(:partial => 'subcontractor_requests/subcontractor_request', :collection => collection)
    html << "</div>"
  end
  
  def display_subcontractor_request_add_button(survey_step)
    content_tag( :p, link_to_function "Ajouter un travail de sous-traitance" do |page|
      page.insert_html :bottom, :new_subcontractor_requests, :partial  => 'subcontractor_requests/subcontractor_request',
                                                             :object   => survey_step.subcontractor_requests.build
      page[:new_subcontractor_requests].show if page[:new_subcontractor_requests].visible
      last_element = page[:new_subcontractor_requests].select('.subcontractor_request').last
      last_element.show
      last_element.visual_effect :highlight
      page.call 'initialize_autoresize_text_areas'
    end )
  end
  
  def display_subcontractor_request_edit_button(subcontractor_request)
    link_to_function "Modifier", "mark_resource_for_update(this, {afterFinish: function(){ initialize_autoresize_text_areas() }})" if is_form_view?
  end
  
  def display_subcontractor_request_delete_button(subcontractor_request)
    link_to_function "Supprimer", "mark_resource_for_destroy(this)" if is_form_view?
  end
  
  def display_subcontractor_request_close_form_button(subcontractor_request)
    if subcontractor_request.new_record?
      link_to_function "Annuler la création de la sous-traitance", "cancel_creation_of_new_resource(this)"
    else is_form_view?
      link_to_function "Annuler la modification de la sous-traitance", "mark_resource_for_dont_update(this)"
    end
  end
  
end
