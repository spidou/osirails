require 'lib/features/thirds/app/helpers/thirds_helper'

module ThirdsHelper
  ### Subcontractor
  def subcontractor_action_buttons(subcontractor)
    html = []
    html << subcontractor_link(subcontractor) unless is_show_view?
    html << edit_subcontractor_link(subcontractor) unless is_edit_view?
    html << delete_subcontractor_link(subcontractor)
    html.compact
  end
  
  alias_method :query_td_for_name_in_subcontractor, :query_td_for_name_in_customer # original method in thirds > thirds_helper
  alias_method :query_td_for_legal_form_name_in_subcontractor, :query_td_for_legal_form_name_in_customer # original method in thirds > thirds_helper
  alias_method :query_td_for_activity_sector_reference_get_activity_sector_name_in_subcontractor,
               :query_td_for_activity_sector_reference_get_activity_sector_name_in_supplier # original method in thirds > thirds_helper
end
