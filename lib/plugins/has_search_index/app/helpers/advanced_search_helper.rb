module AdvancedSearchHelper

  # TODO Manage here i18n
  #
  def page_select(page_names, selected = nil)
    values  = page_names.map {|n| [n.to_s.gsub('advanced_', ''), n.to_s]}.unshift(['Veuillez choisir une catégorie', nil])
    options = options_for_select(values, selected)
    select_tag('p', options, :onchange => "$('page_select_form').submit()")
  end
  
end
