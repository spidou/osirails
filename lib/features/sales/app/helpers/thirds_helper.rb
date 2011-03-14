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
end
