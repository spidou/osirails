module SuppliesManagerHelper
  
  def supply_category_action_buttons(supply_category)
    supply_category_classname = supply_category.class.name.underscore # CommodityCategory => commodity_category
    supply_sub_category_classname = supply_category_classname.gsub("_category", "_sub_category") # commodity_category => commodity_sub_category
    supply_classname = supply_category_classname.gsub("_category", "") # commodity_category => commodity
    
    html = []
    html << send("#{supply_category_classname}_link", supply_category) unless is_show_view?
    html << send("edit_#{supply_category_classname}_link", supply_category) if !is_edit_view? and supply_category.can_be_edited?
    html << disable_supply_category_link(supply_category)
    html << enable_supply_category_link(supply_category)
    html << send("delete_#{supply_category_classname}_link", supply_category) if supply_category.can_be_destroyed?
    html << send("new_#{supply_sub_category_classname}_link", :link_text => "Nouvelle sous-famille",
                                                              :options => { :supply_category_id => supply_category.id },
                                                              :html_options => { "data-icon" => :new_sub_category }) if supply_category.can_have_children?
    html << new_supply_link(supply_classname.camelize.constantize, :supply_category_id => supply_category.id) if supply_category.can_have_children?
    html.compact
  end
  
  def disable_supply_category_link(supply_category, message = nil) 
    return unless supply_category.class.can_disable?(current_user) and supply_category.can_be_disabled?
    message ||= "Désactiver"
    link_to(message,
            self.send("disable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :disable_category)
  end
  
  def enable_supply_category_link(supply_category, message = nil) 
    return unless supply_category.class.can_enable?(current_user) and supply_category.can_be_enabled?
    message ||= "Restaurer"
    link_to(message,
            self.send("enable_#{supply_category.class.name.underscore}_path", supply_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :enable_category)
  end
  
  def supply_sub_category_action_buttons(supply_sub_category)
    supply_sub_category_classname = supply_sub_category.class.name.underscore # CommoditySubCategory => commodity_sub_category
    supply_classname = supply_sub_category_classname.gsub("_sub_category", "") # commodity_sub_category => commodity
    
    html = []
    html << send("#{supply_sub_category_classname}_link", supply_sub_category) unless is_show_view?
    html << send("edit_#{supply_sub_category_classname}_link", supply_sub_category) unless is_edit_view?
    html << disable_supply_sub_category_link(supply_sub_category)
    html << enable_supply_sub_category_link(supply_sub_category)
    html << send("delete_#{supply_sub_category_classname}_link", supply_sub_category)
    html << new_supply_link(supply_classname.camelize.constantize, :supply_sub_category_id => supply_sub_category.id)
    html.compact
  end
  
  def disable_supply_sub_category_link(supply_sub_category, message = nil) 
    return unless supply_sub_category.class.can_disable?(current_user) and supply_sub_category.can_be_disabled?
    message ||= "Désactiver"
    link_to(message,
            self.send("disable_#{supply_sub_category.class.name.underscore}_path", supply_sub_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :disable_category)
  end
  
  def enable_supply_sub_category_link(supply_sub_category, message = nil) 
    return unless supply_sub_category.class.can_enable?(current_user) and supply_sub_category.can_be_enabled?
    message ||= "Restaurer"
    link_to(message,
            self.send("enable_#{supply_sub_category.class.name.underscore}_path", supply_sub_category),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :enable_category)
  end
  
  def new_supply_category_link(supply_category_class)
    return unless supply_category_class.can_add?(current_user)
    link_to("Nouvelle famille",
            self.send("new_#{supply_category_class.name.underscore}_path"),
            'data-icon' => :new)
  end
  
  def new_supply_sub_category_link(supply_sub_category_class)
    return unless supply_sub_category_class.can_add?(current_user)
    link_to("Nouvelle sous-famille",
            self.send("new_#{supply_sub_category_class.name.underscore}_path"),
            'data-icon' => :new_sub_category)
  end
  
  def new_supply_link(supply_class, link_options = {})
    return unless supply_class.can_add?(current_user)
    link_to("Nouvel article",
            self.send("new_#{supply_class.name.underscore}_path", link_options ),
            'data-icon' => :new)
  end
  
  def supply_action_buttons(supply)
    supply_classname = supply.class.name.underscore # Commodity => commodity
    
    html = []
    html << send("#{supply_classname}_link", supply) unless is_show_view?
    html << send("edit_#{supply_classname}_link", supply) unless is_edit_view?
    html << disable_supply_link(supply)
    html << enable_supply_link(supply)
    html << send("delete_#{supply_classname}_link", supply)
    html << watching_link(supply)
    html.compact
  end
  
  def disable_supply_link(supply)
    return unless supply.class.can_disable?(current_user) and supply.can_be_disabled?
    message ||= "Désactiver"
    link_to(message,
            self.send("disable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :disable_supply)
  end
  
  def enable_supply_link(supply)
    return unless supply.class.can_enable?(current_user) and supply.can_be_enabled?
    message ||= "Restaurer"
    link_to(message,
            self.send("enable_#{supply.class.name.underscore}_path", supply),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :enable_supply)
  end
  
  #TODO remove that helper after creating additional queries via has_search_index plugin (seeds)
  def display_supply_list_button(supply_class)
    return unless supply_class.can_list?(current_user)
    message ||= (supply_class == Consumable ? 'Voir tous les consommables' : 'Voir toutes les matières premières')
    link_to(message,
            self.send("#{supply_class.name.tableize}_manager_path"),
            'data-icon' => :index)
  end
  
  #TODO remove that helper after creating additional queries via has_search_index plugin (seeds)
  def display_supply_list_all_button(supply_class, all = false)
    return unless supply_class.can_list?(current_user)
    message ||= (supply_class == Consumable ? 'Voir tous les consommables (y compris ceux qui sont désactivés)' : 'Voir toutes les matières premières (y compris celles qui sont désactivées)')
    link_to(message,
            self.send("#{supply_class.name.tableize}_manager_path", :inactives => "1"),
            'data-icon' => :index)
  end
  
  def humanized_supply_sizes_and_packaging(supply)
    text = supply.humanized_supply_sizes.gsub(" ", "&#160;")
    text << "&#160;<span class=\"packaging\">(#{supply.packaging}&#160;U/lot)</span>" unless supply.packaging.blank?
    text
  end
  
  def query_td_for_reference_in_commodity(content)
    content_tag(:td, link_to(content, @query_object), :class => :reference)
  end
  alias_method :query_td_for_reference_in_consumable, :query_td_for_reference_in_commodity
  
  def query_td_for_designation_in_commodity(content)
    content_tag(:td, link_to(content, @query_object), :class => "designation text")
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
