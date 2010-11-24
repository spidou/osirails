module AdvancedSearchHelper

  def page_select(page_names, selected = nil)
    values  = page_names.map do |page_name|
      model = HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym][:model].tableize.singularize
      [I18n.t("activerecord.models.#{ model }", :default => model.humanize), page_name.to_s]
    end
    values.unshift([I18n.t('view.advanced_search.model_select.default'), nil])
    
    options = options_for_select(values, selected)
    select_tag('p', options, :onchange => "$('page_select_form').submit()")
  end
  
  include EmployeesHelper
end
