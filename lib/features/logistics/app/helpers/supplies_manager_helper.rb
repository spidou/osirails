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
      message ||= (supply_category.class == ConsumableCategory ? 'Nouvelle famille de consommable' : 'Nouvelle famille de matière première')
      link_to(message,
              self.send("new_#{supply_category.class.singularized_table_name}_path"),
              'data-icon' => :new)
      
    elsif supply_category.respond_to?(:supply_category) # to add a supply
      supply_type = supply_category.class.name.gsub("SubCategory", "").constantize
      
      return unless supply_type.can_add?(current_user) and supply_category.can_have_children?
      message ||= (supply_type == Consumable ? 'Nouveau consommable' : 'Nouvelle matière première')
      link_to(message,
              self.send("new_#{supply_type.name.underscore}_path", :supply_category_id => supply_category.id),
              'data-icon' => :new)
      
    else # to add a supply_sub_category
      supply_sub_category_type = supply_category.class.name.gsub("Category", "SubCategory").constantize
      
      return unless supply_sub_category_type.can_add?(current_user) and supply_category.can_have_children?
      message ||= (supply_category.class == ConsumableCategory ? 'Nouvelle sous-famille de consommable' : 'Nouvelle sous-famille de matière première')
      link_to(message,
              self.send("new_#{supply_sub_category_type.name.underscore}_path", :supply_category_id => supply_category.id),
              'data-icon' => :new_sub_category)
      
    end
  end
  
  def display_supply_category_show_button(supply_category, message = nil)
    return unless supply_category.class.can_view?(current_user)
    message ||= "Voir la famille"
    link_to(message,
            self.send("#{supply_category.class.name.underscore}_path", supply_category),
            'data-icon' => :show)
  end
  
  def display_supply_category_edit_button(supply_category, message = nil)
    return unless supply_category.class.can_edit?(current_user) and supply_category.can_be_edited?
    message ||= "Modifier la famille"
    link_to(message,
            self.send("edit_#{supply_category.class.name.underscore}_path", supply_category),
            'data-icon' => :edit)
  end
  
  def display_supply_category_enable_button(supply_category, message = nil) 
    return unless supply_category.class.can_enable?(current_user) and supply_category.can_be_enabled?
    message ||= "Restaurer la famille"
    link_to(message,
            self.send("enable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :enable_category)
  end
  
  def display_supply_category_disable_button(supply_category, message = nil)
    return unless supply_category.class.can_disable?(current_user) and supply_category.can_be_disabled?
    message ||= "Désactiver la famille"
    link_to(message,
            self.send("disable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => 'disable_category')
  end
  
  def display_supply_category_delete_button(supply_category, message = nil)
    return unless supply_category.class.can_delete?(current_user) and supply_category.can_be_destroyed?
    message ||= "Supprimer la famille"
    link_to(message,
            supply_category,
            :method => :delete,
            :confirm => 'Êtes vous sûr ?',
            'data-icon' => :delete)
  end
  
  def display_supply_add_button(supply, message = nil)
    return unless supply.class.can_add?(current_user) and supply.enabled?
    message ||= supply.is_a?(Consumable) ? "Nouveau consommable" : "Nouvelle matière première"
    link_to(message,
            self.send("new_#{supply.class.singularized_table_name}_path"),
            'data-icon' => :new)
  end
  
  def display_supply_action_buttons(supply)
    html = []
    html << watching_button(supply)
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
    message ||= "Voir " + get_text_for_supply_type(supply)
    link_to(message,
            send("#{supply.class.singularized_table_name}_path", supply),
            'data-icon' => :show)
  end
  
  def display_supply_edit_button(supply, message = nil) 
    return unless supply.class.can_edit?(current_user) and supply.can_be_edited?
    message ||= "Modifier " + get_text_for_supply_type(supply)
    link_to(message,
            send("edit_#{supply.class.singularized_table_name}_path", supply),
            'data-icon' => :edit)
  end
  
  def display_supply_disable_button(supply, message = nil) 
    return unless supply.class.can_disable?(current_user) and supply.can_be_disabled?
    message ||= "Désactiver " + get_text_for_supply_type(supply)
    link_to(message,
            self.send("disable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :disable_supply)
  end
  
  def display_supply_enable_button(supply, message = nil) 
    return unless supply.class.can_enable?(current_user) and supply.can_be_enabled?
    message ||= "Restaurer " + get_text_for_supply_type(supply)
    message ||= " #{text}"
    link_to(message,
            self.send("enable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :enable_supply)
  end
  
  def display_supply_delete_button(supply, message = nil) 
    return unless supply.class.can_delete?(current_user) and supply.can_be_destroyed?
    message ||= "Supprimer " + get_text_for_supply_type(supply)
    link_to(message, supply,
            :method => :delete,
            :confirm => 'Êtes vous sûr ?',
            'data-icon' => :delete)
  end
  
  def display_supply_list_button(supply_type)
    return unless supply_type.can_list?(current_user)
    message ||= (supply_type == Consumable ? 'Voir tous les consommables' : 'Voir toutes les matières premières')
    link_to(message,
            self.send("#{supply_type.name.tableize}_manager_path"),
            'data-icon' => :index)
  end
  
  def display_supply_list_all_button(supply_type, all = false)
    return unless supply_type.can_list?(current_user)
    message ||= (supply_type == Consumable ? 'Voir tous les consommables (y compris ceux qui sont désactivés)' : 'Voir toutes les matières premières (y compris celles qui sont désactivées)')
    link_to(message,
            self.send("#{supply_type.name.tableize}_manager_path", :inactives => "1"),
            'data-icon' => :index)
  end
  
  def humanized_supply_sizes_and_packaging(supply)
    text = supply.humanized_supply_sizes.gsub(" ", "&#160;")
    text << "&#160;<span class=\"packaging\">(#{supply.packaging}&#160;U/lot)</span>" unless supply.packaging.blank?
    text
  end
  
  def query_td_for_reference_in_commodity(content)
    content_tag(:td, content, :class => :reference)
  end
  alias_method :query_td_for_reference_in_consumable, :query_td_for_reference_in_commodity
  
  def query_td_for_designation_in_commodity(content)
    content_tag(:td, content, :class => "designation text")
  end
  alias_method :query_td_for_designation_in_consumable, :query_td_for_designation_in_commodity
  
  def query_td_for_measure_in_commodity(content)
    content_tag(:td, content, :class => :unit_measure)
  end
  alias_method :query_td_for_measure_in_consumable, :query_td_for_measure_in_commodity
  
  def query_td_content_for_measure_in_commodity
    unit_measure_symbol = @query_object.unit_measure.symbol if @query_object.unit_measure
    @query_object.measure ? "#{@query_object.measure} #{unit_measure_symbol}" : "-"
  end
  alias_method :query_td_content_for_measure_in_consumable, :query_td_content_for_measure_in_commodity
  
  def query_td_for_unit_mass_price_in_commodity(content)
    content_tag(:td, content, :class => :unit_mass)
  end
  alias_method :query_td_for_unit_mass_price_in_consumable, :query_td_for_unit_mass_price_in_commodity
  
  def query_td_content_for_unit_mass_in_commodity
    @query_object.unit_mass ? "#{@query_object.unit_mass} kg" : "-"
  end
  alias_method :query_td_content_for_unit_mass_in_consumable, :query_td_content_for_unit_mass_in_commodity
  
  def query_td_for_average_unit_price_in_commodity(content)
    content_tag(:td, content, :class => "average_unit_price amount")
  end
  alias_method :query_td_for_average_unit_price_in_consumable, :query_td_for_average_unit_price_in_commodity
  
  def query_td_content_for_average_unit_price_in_commodity
    @query_object.average_unit_price ? "#{number_with_precision(@query_object.average_unit_price, :precision => 2)} &euro;" : "-"
  end
  alias_method :query_td_content_for_average_unit_price_in_consumable, :query_td_content_for_average_unit_price_in_commodity
  
  def query_td_for_average_measure_price_in_commodity(content)
    content_tag(:td, content, :class => "average_measure_price amount")
  end
  alias_method :query_td_for_average_measure_price_in_consumable, :query_td_for_average_measure_price_in_commodity
  
  def query_td_content_for_average_measure_price_in_commodity
    @query_object.average_measure_price ? "#{number_with_precision(@query_object.average_measure_price, :precision => 2)} &euro;/#{display_supply_unit_measure(@query_object)}" : "-"
  end
  alias_method :query_td_content_for_average_measure_price_in_consumable, :query_td_content_for_average_measure_price_in_commodity
end
