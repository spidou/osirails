module SuppliesManagerHelper
  def display_supply_category_action_buttons(supply_category)
    html = []
    html << display_supply_category_add_button(supply_category, '')
    html << display_supply_category_show_button(supply_category, '')
    html << display_supply_category_edit_button(supply_category, '')
    html << display_supply_category_disable_button(supply_category, '')
    html << display_supply_category_enable_button(supply_category, '')
    html << display_supply_category_delete_button(supply_category, '')
    html.compact.join("&nbsp;")
  end
  
  def display_supply_category_add_button(supply_category, message = nil)
    if supply_category.new_record? # to add a supply_category
      
      return unless supply_category.class.can_add?(current_user)
      text = (supply_category.class == ConsumableCategory ? 'Nouvelle famille de consommable' : 'Nouvelle famille de matière première')
      message ||= " #{text}"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + message,
              self.send("new_#{supply_category.class.singularized_table_name}_path"))
      
    elsif supply_category.respond_to?(:supply_category) # to add a supply
      supply_type = supply_category.class.name.gsub("SubCategory", "").constantize
      
      return unless supply_type.can_add?(current_user) and supply_category.can_have_children?
      text = (supply_type == Consumable ? 'Nouveau consommable' : 'Nouvelle matière première')
      message ||= " #{text}"
      link_to(image_tag("add_16x16.png", :alt => text, :title => text) + message,
              self.send("new_#{supply_type.name.underscore}_path", :supply_category_id => supply_category.id))
      
    else # to add a supply_sub_category
      supply_sub_category_type = supply_category.class.name.gsub("Category", "SubCategory").constantize
      
      return unless supply_sub_category_type.can_add?(current_user) and supply_category.can_have_children?
      text = (supply_category.class == ConsumableCategory ? 'Nouvelle sous-famille de consommable' : 'Nouvelle sous-famille de matière première')
      message ||= " #{text}"
      link_to(image_tag("category_16x16.png", :alt => text , :title => text) + message,
              self.send("new_#{supply_sub_category_type.name.underscore}_path", :supply_category_id => supply_category.id))
      
    end
  end
  
  def display_supply_category_show_button(supply_category, message = nil)
    return unless supply_category.class.can_view?(current_user)
    text = "Voir la famille"
    message ||= " #{text}"
    link_to(image_tag("view_16x16.png", :alt => text, :title => text) + message,
            self.send("#{supply_category.class.name.underscore}_path", supply_category))
  end
  
  def display_supply_category_edit_button(supply_category, message = nil)
    return unless supply_category.class.can_edit?(current_user) and supply_category.can_be_edited?
    text = "Modifier la famille"
    message ||= " #{text}"
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text) + message,
            self.send("edit_#{supply_category.class.name.underscore}_path", supply_category))
  end
  
  def display_supply_category_enable_button(supply_category, message = nil) 
    return unless supply_category.class.can_enable?(current_user) and supply_category.can_be_enabled?
    text = "Restaurer la famille"
    message ||= " #{text}"
    link_to(image_tag("tick_16x16.png", :alt => text, :title => text) + message,
            self.send("enable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?")
  end
  
  def display_supply_category_disable_button(supply_category, message = nil)
    return unless supply_category.class.can_disable?(current_user) and supply_category.can_be_disabled?
    text = "Désactiver la famille"
    message ||= " #{text}"
    link_to(image_tag("cancel_16x16.png", :alt => text, :title => text) + message,
            self.send("disable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?") 
  end
  
  def display_supply_category_delete_button(supply_category, message = nil)
    return unless supply_category.class.can_delete?(current_user) and supply_category.can_be_destroyed?
    text = "Supprimer la famille"
    message ||= " #{text}"
    link_to(image_tag("delete_16x16.png", :alt => text, :title => text) + message,
            supply_category,
            { :method => :delete, :confirm => 'Êtes vous sûr  ?'})
  end
  
  def display_supply_add_button(supply, message = nil)
    return unless supply.class.can_add?(current_user) and supply.enabled?
    text = supply.class == "Consumable" ? "Nouveau consommable" : "Nouvelle matière première"
    message ||= " #{text}"
    link_to(image_tag("add_16x16.png", :alt => text , :title => text) + message,
            self.send("new_#{supply.class.singularized_table_name}_path"))
  end
  
  def display_supply_action_buttons(supply)
    html = []
    html << display_supply_show_button(supply, '')
    html << display_supply_edit_button(supply, '')
    html << display_supply_disable_button(supply, '')
    html << display_supply_enable_button(supply, '')
    html << display_supply_delete_button(supply, '')
    html.compact.join("&nbsp;")
  end
  
  def get_text_for_supply_type(supply)
    case supply.class.name
    when "Consumable"
      'le consommable'
    when "Commodity"
      'la matière première'
    else
      supply.class.name
    end
  end
  
  def display_supply_show_button(supply, message = nil) 
    return unless supply.class.can_view?(current_user)
    text = "Voir " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(image_tag("view_16x16.png", :alt => text, :title => text) + message,
                      send("#{supply.class.singularized_table_name}_path", supply))
  end
  
  def display_supply_edit_button(supply, message = nil) 
    return unless supply.class.can_edit?(current_user) and supply.can_be_edited?
    text = "Modifier " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text) + message,
            send("edit_#{supply.class.singularized_table_name}_path", supply))
  end
  
  def display_supply_disable_button(supply, message = nil) 
    return unless supply.class.can_disable?(current_user) and supply.can_be_disabled?
    text = "Désactiver " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(image_tag("cancel_16x16.png", :alt => text, :title => text) + message,
            self.send("disable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?")
  end
  
  def display_supply_enable_button(supply, message = nil) 
    return unless supply.class.can_enable?(current_user) and supply.can_be_enabled?
    text = "Restaurer " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(image_tag("tick_16x16.png", :alt => text, :title => text) + message,
            self.send("enable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?")
  end
  
  def display_supply_delete_button(supply, message = nil) 
    return unless supply.class.can_delete?(current_user) and supply.can_be_destroyed?
    text = "Supprimer " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(image_tag("delete_16x16.png", :alt => text, :title => text) + message,
            supply, { :controller => supply.class.name.tableize, :action => 'destroy', :method => :delete, :confirm => 'Êtes-vous sûr  ?'})
  end
  
  def display_supply_list_button(supply_type)
    if supply_type.can_list?(current_user)
      text = (supply_type == Consumable ? 'Voir tous les consommables' : 'Voir toutes les matières premières')
      message ||= " #{text}"
      link_to(image_tag("list_16x16.png", :alt => text, :title => text ) + message,
              self.send("#{supply_type.name.tableize}_manager_path"))
    end
  end
  
  def display_supply_list_all_button(supply_type, all = false)
    if supply_type.can_list?(current_user)
      text = (supply_type == Consumable ? 'Voir tous les consommables (y compris ceux qui sont désactivés)' : 'Voir toutes les matières premières (y compris celles qui sont désactivées)')
      message ||= " #{text}"
      link_to(image_tag("list_16x16.png", :alt => text, :title => text ) + message,
              self.send("#{supply_type.name.tableize}_manager_path", :inactives => "1"))
    end
  end
  
  def humanized_supply_sizes_and_packaging(supply)
    text = supply.humanized_supply_sizes.gsub(" ", "&#160;")
    text << "&#160;<span class=\"packaging\">(#{supply.packaging}&#160;U/lot)</span>" unless supply.packaging.blank?
    text
  end
  
end
