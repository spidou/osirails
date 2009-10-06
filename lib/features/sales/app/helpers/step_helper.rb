module StepHelper

  def display_checklist(checklist_responses, step)
    action = params[:action]
    html = ""
    unless checklist_responses.empty?
      html = " <h2> Checklist </h2>"
      for checklist_response in checklist_responses
        fields_for "#{step.class.name.tableize.singularize}[checklists]", checklist_response, :index => checklist_response.id do |checklist_|
          if action == "edit"
            html += "<p>"
            html += checklist_.label "checklist", "#{checklist_response.checklist.name} :" + "&nbsp;"
            unless checklist_response.checklist.checklist_options.empty?
              html += checklist_.select("answer", checklist_response.checklist.checklist_options.collect {|a| [ a.name, a.name ] }, {:include_blank => ""})
            else
              html += checklist_.select("answer", { "" => "", "Oui" => "oui", "Non" => "non"})
            end
            html += "</p>"
          elsif action == "show"
            html += "<p>"
            html += checklist_.label "checklist", "#{checklist_response.checklist.name} :" + "&nbsp;"
            checklist_response.answer.nil? ? response = "indéfinie" : response = checklist_response.answer
            html += response
            html += "</p>"
          end
        end
      end
    end
    return html
  end

  def display_remarks_and_add_remark_text_area(remarks, step)
    html = "<p>"
    html += display_remarks(remarks)
    html += "<p>"

    html += "<p>"
    html += display_add_remark_text_area(step)
    html += "</p>"
    return html
  end
  
  def display_remarks(remarks)
    html = "<h2> Commentaires </h2>"
    unless remarks.empty?
      for remark in remarks.reverse
        html += "<p>"
        html += "Posté par <strong> #{remark.user.employee ? remark.user.employee.fullname : remark.user.username}</strong> le #{remark.created_at.strftime('%d %B %Y')} à #{remark.created_at.strftime('%H:%M')} : <br/>"
        html += "<span class='indent'>"
        html += "#{remark.text}"
        html += "</span>"
        html += "</p>"      
      end
    else
      html += "<p>"
      html += "Aucun commentaires"
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
