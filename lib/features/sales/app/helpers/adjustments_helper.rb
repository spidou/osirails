module AdjustmentsHelper
  
  def display_adjustments_list_for(due_date)
    id = due_date.was_paid? ? '' : " id=\"new_adjustments_for_due_date_#{due_date.id}\""
    
    html = "<div class=\"adjustments\"#{id}>"
    html << render(:partial => 'adjustments/adjustment', :collection => due_date.adjustments, :locals => { :due_date => due_date }) unless due_date.adjustments.empty?
    html << '</div>'
  end
  
  def display_adjustment_add_link(due_date)
    link_to_function "Nouvel ajustement" do |page|
      div_id = "new_adjustments_for_due_date_#{due_date.id}"
      page.insert_html :bottom, div_id, :partial  => 'adjustments/adjustment',
                                        :object   => due_date.adjustments.build,
                                        :locals   => { :due_date => due_date }
      last_adjustment = page[div_id].select('.adjustment').last
      last_adjustment.show
      last_adjustment.visual_effect :highlight
      page.call 'initialize_autoresize_text_areas'
    end
  end
  
  def display_adjustment_remove_link
    content_tag( :p, link_to_function("Supprimer", "this.up('.adjustment').remove()") )
  end
end
