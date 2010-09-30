module ProductionStepsHelper
  
  def display_production_step_show_button(order)
    text = title = "voir l'etape production"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt    => title || text,
                        :title  => title || text ),
              order_pre_invoicing_step_production_step_path(order) )
  end
  
  def display_production_step_edit_button(order)
    text = title = "Modifier l'etape production"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt    => title || text,
                        :title  => title || text ),
            edit_order_pre_invoicing_step_production_step_path(order) )
  end
  
  def display_production_step_action_buttons(order)
    html = []
    html << display_production_step_show_button(order)
    html << display_production_step_edit_button(order)
    html.compact.join("&nbsp;")
  end
  
end
