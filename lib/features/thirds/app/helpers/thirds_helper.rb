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
  
  def query_td_for_name_in_customer(content)
    content_tag(:td, link_to(content, @query_object), :class => :text)
  end
  
  def query_td_for_legal_form_name_in_customer(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_for_brand_names_in_customer(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_brand_names_in_customer
    @query_object.brand_names.join(', ')
  end
  
  def query_td_for_head_office_activity_sector_reference_get_activity_sector_name_in_customer(content)
    content_tag(:td, content, :class => :text)
  end
  
  ### Supplier
  def supplier_action_buttons(supplier)
    html = []
    html << supplier_link(supplier) unless is_show_view?
    html << edit_supplier_link(supplier) unless is_edit_view?
    html << delete_supplier_link(supplier)
    html.compact
  end
  
  alias_method :query_td_for_name_in_supplier, :query_td_for_name_in_customer
  alias_method :query_td_for_legal_form_name_in_supplier, :query_td_for_legal_form_name_in_customer
  
  def query_td_for_activity_sector_reference_get_activity_sector_name_in_supplier(content)
    content_tag(:td, content, :class => :text)
  end
end
