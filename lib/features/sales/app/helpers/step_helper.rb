module StepHelper
  
  def display_checklist(checklist_responses, step)
    html = " <h2> Checklist </h2> "
    for checklist_response in checklist_responses
      fields_for "#{step.class.name.tableize.singularize}[checklists]", checklist_response, :index => checklist_response.id do |checklist_|
#        if StepSurvey.can_edit?(current_user)
          html += "<p>"
          html += checklist_.label "checklist", "#{checklist_response.checklist.name} :" + "&nbsp;"
          unless checklist_response.checklist.checklist_options.empty?
            html += checklist_.select("answer", checklist_response.checklist.checklist_options.collect {|a| [ a.name, a.name ] }, {:include_blank => ""})
          else
            html += checklist_.select("answer", { "" => "", "Oui" => "oui", "Non" => "non"})
          end
          html += "</p>"
#        elsif StepSurvey.can_view?(current_user)
          html += "<p>"
          html += checklist_.label "checklist", "#{checklist_response.checklist.name} :" + "&nbsp;"
          html += a = ChecklistResponse.find_by_has_checklist_response_type_and_has_checklist_response_id_and_checklist_id(step.class.name,step.id,checklist_response.id).answer unless a.nil?
          html += "</p>"
#        end
      end
    end
    return html
  end
  
  def display_remarks_and_add_remark_text_area(remarks, step)
    step_name = step.class.name.tableize.split("_")
    step_name.shift ## remove the 'step' caracteres before step name
    step_controller = Menu.find_by_name("#{step_name[0]}")
    html = ""
#    if step_controller.can_list?(current_user)
      html += "<p>"
      html += display_remarks(remarks)
      html += "<p>"
#    end
    
#    if step_controller.can_add?(current_user)
      html += "<p>"
      html += display_add_remark_text_area(step)
      html += "</p>"
#    end
    return html
  end
  
  def display_remarks(remarks)
    html = "<h2> Commentaires </h2>"
    for remark in remarks.reverse
      html += "<p>"
      html += "Post&eacute; par <strong> #{remark.user.employee.fullname}</strong> le #{remark.created_at.strftime('%d %B %Y')} à #{remark.created_at.strftime('%H:%M')} : <br/>"
      html += "<span class='indent'>"
      html += "#{remark.text}"
      html += "</span>"
      html += "</p>"      
    end
    return html
  end
  
  def display_add_remark_text_area(step)
    remark = Remark.new
    html = ""
    fields_for "#{step.class.name.tableize.singularize}[remark]", remark do |remark_|
      html += "<p>"
      html += remark_.label :text, "Ajouter un commentaire :"
      html += remark_.text_area :text , :size => "60x2"
      html += "</p>"
    end
  end
  
end