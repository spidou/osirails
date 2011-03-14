module ThirdsHelper
  ### Customer
  def customer_action_buttons(customer)
    html = []
    html << customer_link(customer) unless is_show_view?
    html << edit_customer_link(customer) unless is_edit_view?
    html << delete_customer_link(customer)
    html << display_new_order_from_customer_button(customer)
    html.compact
  end
  
  def display_new_order_from_customer_button(customer, message = nil)
    return unless Order.can_add?(current_user)
    link_to(message || "Nouveau dossier",
            new_order_path(:customer_id => customer.id),
            'data-icon' => :new)
  end
  
  ### Supplier
  def supplier_action_buttons(supplier)
    html = []
    html << supplier_link(supplier) unless is_show_view?
    html << edit_supplier_link(supplier) unless is_edit_view?
    html << delete_supplier_link(supplier)
    html.compact
  end
end
