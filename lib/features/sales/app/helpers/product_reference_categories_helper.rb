module ProductReferenceCategoriesHelper
  
  def display_product_reference_category_add_button(message = nil)
    return unless ProductReferenceCategory.can_add?(current_user)
    link_to_unless_current(message || 'Nouvelle famille',
                           new_product_reference_category_path,
                           'data-icon' => :new) {nil}
  end
  
  def display_product_reference_sub_category_add_button(message = nil)
    return unless ProductReferenceSubCategory.can_add?(current_user)
    link_to_unless_current(message || 'Nouvelle sous-famille',
                           new_product_reference_sub_category_path,
                           'data-icon' => :new) {nil}
  end

  def product_reference_category_action_buttons(category)
    html = []
    html << display_product_reference_category_new_sub_category_button(category)
    
    html << display_product_reference_category_show_button(category)
    html << display_product_reference_category_edit_button(category)
    html << display_product_reference_category_disable_button(category)
    html << display_product_reference_category_enable_button(category)
    html << display_product_reference_category_delete_button(category)
    html.compact
  end
  
  def display_product_reference_category_new_sub_category_button(category, message = nil)
    return unless ProductReferenceSubCategory.can_add?(current_user)
    link_to_unless_current(message || 'Nouvelle sous-famille',
                           new_product_reference_sub_category_path(:product_reference_category_id => category.id),
                           'data-icon' => :new_sub_category) {nil}
  end
  
  def display_product_reference_category_show_button(category, message = nil)
    return unless ProductReferenceCategory.can_view?(current_user)
    link_to_unless_current(message || I18n.t('view.links.show'),
                           category,
                           'data-icon' => :show) {nil}
  end
  
  def display_product_reference_category_edit_button(category, message = nil)
    return unless ProductReferenceCategory.can_edit?(current_user)
    link_to_unless_current(message || I18n.t('view.links.edit'),
                           edit_product_reference_category_path(category),
                           'data-icon' => :edit) {nil}
  end
  
  def display_product_reference_category_disable_button(category, message = nil)
    return unless ProductReferenceCategory.can_disable?(current_user) and category.can_be_disabled?
    link_to(message || "Désactiver",
            product_reference_category_disable_path(category),
            :confirm => "Êtes vous sûr?",
            'data-icon' => :disable)
  end
  
  def display_product_reference_category_enable_button(category, message = nil)
    return unless ProductReferenceCategory.can_enable?(current_user) and category.can_be_enabled?
    link_to(message || "Restaurer",
            product_reference_category_enable_path(category),
            :confirm => "Êtes vous sûr?",
            'data-icon' => :enable)
  end
  
  def display_product_reference_category_delete_button(category, message = nil)
    return unless ProductReferenceCategory.can_delete?(current_user) and category.can_be_destroyed?
    link_to(message || I18n.t('view.links.delete'),
            category,
            :method => :delete,
            :confirm => I18n.t('view.links.confirm'),
            'data-icon' => :delete)
  end
  
  def product_reference_sub_category_action_buttons(sub_category)
    html = []
    html << display_product_reference_category_new_product_reference_button(sub_category)
    
    html << display_product_reference_sub_category_show_button(sub_category)
    html << display_product_reference_sub_category_edit_button(sub_category)
    html << display_product_reference_sub_category_disable_button(sub_category)
    html << display_product_reference_sub_category_enable_button(sub_category)
    html << display_product_reference_sub_category_delete_button(sub_category)
    html.compact
  end
  
  def display_product_reference_category_new_product_reference_button(sub_category, message = nil)
    return unless ProductReference.can_add?(current_user)
    link_to_unless_current(message || 'Nouveau produit référence',
                           new_product_reference_path(:product_reference_sub_category_id => sub_category.id),
                           'data-icon' => :new_product_reference) {nil}
  end
  
  def display_product_reference_sub_category_show_button(sub_category, message = nil)
    return unless ProductReferenceSubCategory.can_view?(current_user)
    link_to_unless_current(message || I18n.t('view.links.show'),
                           sub_category,
                           'data-icon' => :show) {nil}
  end
  
  def display_product_reference_sub_category_edit_button(sub_category, message = nil)
    return unless ProductReferenceSubCategory.can_edit?(current_user)
    link_to_unless_current(message || I18n.t('view.links.edit'),
                           edit_product_reference_sub_category_path(sub_category),
                           'data-icon' => :edit) {nil}
  end
  
  def display_product_reference_sub_category_disable_button(sub_category, message = nil)
    return unless ProductReferenceSubCategory.can_disable?(current_user) and sub_category.can_be_disabled?
    link_to(message || "Désactiver",
            product_reference_sub_category_disable_path(sub_category),
            :confirm => I18n.t('view.links.confirm'),
            'data-icon' => :disable)
  end
  
  def display_product_reference_sub_category_enable_button(sub_category, message = nil)
    return unless ProductReferenceSubCategory.can_enable?(current_user) and sub_category.can_be_enabled?
    link_to(message || "Restaurer",
            product_reference_sub_category_enable_path(sub_category),
            :confirm => I18n.t('view.links.confirm'),
            'data-icon' => :enable)
  end
  
  def display_product_reference_sub_category_delete_button(sub_category, message = nil)
    return unless ProductReferenceSubCategory.can_delete?(current_user) and sub_category.can_be_destroyed?
    link_to(message || I18n.t('view.links.delete'),
            sub_category,
            :method => :delete,
            :confirm => I18n.t('view.links.confirm'),
            'data-icon' => :delete)
  end
  
end
