module ServiceDeliveriesHelper
  def service_delivery_action_buttons(service_delivery)
    html = []
    html << service_delivery_link(service_delivery) unless is_show_view?
    html << edit_service_delivery_link(service_delivery) unless is_edit_view?
    html << delete_service_delivery_link(service_delivery) if service_delivery.can_be_destroyed?
    html.compact
  end
end
