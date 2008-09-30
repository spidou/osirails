module StepHelper
  def display_checklist(checklist, checklist_object, step)
    if StepSurvey.can_edit?(current_user)
      html = checklist.label "checklist", "#{checklist_object.checklist.name} :" + "&nbsp;"
      unless checklist_object.checklist.checklist_options.empty?
        html += checklist.select("answer", checklist_object.checklist.checklist_options.collect {|a| [ a.name, a.name ] }, {:include_blank => ""})
      else
        html += checklist.select("answer", { "" => "", "Oui" => "oui", "Non" => "non"})
      end
    elsif StepSurvey.can_view?(current_user)
      html = checklist.label "checklist", "#{checklist_object.checklist.name} :" + "&nbsp;"
      html += ChecklistResponse.find_by_has_checklist_response_type_and_has_checklist_response_id_and_checklist_id(step.class.name,step.id,checklist_object.id).answer
    end
    return html
  end
  
  def display_remark(remark)
    html = "<p>Post&eacute; par <strong> #{remark.user.employee.fullname}</strong> le #{remark.created_at.strftime('%d %B %Y')} à #{remark.created_at.strftime('%H:%M')} : <br/>"
    html += "<indent>#{remark.text}'</indent></p>"
  end
end