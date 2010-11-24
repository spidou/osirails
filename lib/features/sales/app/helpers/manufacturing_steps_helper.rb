module ManufacturingStepsHelper
  
  def display_manufacturing_step_show_button(order)
    text = title = "Voir l'étape Production"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt    => title || text,
                        :title  => title || text ),
              order_production_step_manufacturing_step_path(order) )
  end
  
  def display_manufacturing_step_edit_button(order)
    text = title = "Modifier l'étape Production"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt    => title || text,
                        :title  => title || text ),
            edit_order_production_step_manufacturing_step_path(order) )
  end
  
  def display_manufacturing_step_action_buttons(order)
    html = []
    html << display_manufacturing_step_show_button(order)
    html << display_manufacturing_step_edit_button(order)
    html.compact.join("&nbsp;")
  end
  
end
