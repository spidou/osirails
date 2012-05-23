require_dependency 'app/helpers/application_helper'

module ApplicationHelper
  private
    # permits to display only steps which are activated for the current order
    def display_menu_entry_with_sales_support(menu, li_options)
      return "" if menu.name && menu.name.ends_with?("_step") && !@order.steps.collect(&:name).include?(menu.name)
      display_menu_entry_without_sales_support(menu, li_options)
    end
    
    alias_method_chain :display_menu_entry, :sales_support
end
