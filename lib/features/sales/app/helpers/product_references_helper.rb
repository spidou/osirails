module ProductReferencesHelper
  
  def display_product_reference_add_button(message = nil)
    return unless ProductReference.can_add?(current_user)
    link_to_unless_current(message || 'Nouveau produit référence',
                           new_product_reference_path,
                           'data-icon' => :new) {nil}
  end
  
  def product_reference_action_buttons(product_reference)
    html = []
    html << display_product_reference_show_button(product_reference)
    html << display_product_reference_edit_button(product_reference)
    html << display_product_reference_delete_button(product_reference)
    html.compact
  end
  
  def display_product_reference_show_button(product_reference, message = nil)
    return unless ProductReference.can_view?(current_user)
    link_to_unless_current(message || I18n.t('view.links.show'),
                           product_reference,
                           'data-icon' => :show) {nil}
  end
  
  def display_product_reference_edit_button(product_reference, message = nil)
    return unless ProductReference.can_edit?(current_user)
    link_to_unless_current(message || I18n.t('view.links.edit'),
                           edit_product_reference_path(product_reference),
                           'data-icon' => :edit) {nil}
  end
  
  def display_product_reference_delete_button(product_reference, message = nil)
    return unless ProductReference.can_delete?(current_user) and product_reference.can_be_destroyed?
    link_to(message || I18n.t('view.links.delete'),
            product_reference,
            :method => :delete,
            :confirm => I18n.t('view.links.confirm'),
            'data-icon' => :delete)
  end
  
  def query_td_for_reference_in_product_reference(content)
    content_tag(:td, link_to(content, @query_object), :class => 'reference text')
  end
  
  def query_td_for_designation_in_product_reference(content)
    content_tag(:td, link_to(content, @query_object), :class => 'designation text')
  end
  
  def query_td_for_description_in_product_reference(content)
    content_tag(:td, content, :class => 'description text')
  end
  
  #TODO this method would have permitted to display count of product_references for categories,
  #     but it's impossible to recover the object of the group right now
  #def query_group_td_content_in_product_reference(group_by)
  #  content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do
  #    group_by.map{ |n| "#{n[:value]} (??)" }.join(" -> ")
  #  end
  #end
  
end
