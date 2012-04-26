require_dependency 'app/helpers/application_helper'

module ApplicationHelperSalesSupport
  private
    # permits to display only steps which are activated for the current order
    def display_menu_entry(menu, li_options)
      return "" if menu.name and menu.name.ends_with?("_step") and !@order.steps.collect(&:name).include?(menu.name)
      super(menu, li_options)
    end
end

ApplicationHelper.extend ApplicationHelperSalesSupport
