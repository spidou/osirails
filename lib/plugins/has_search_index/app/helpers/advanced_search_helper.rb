module AdvancedSearchHelper

  def page_select(page_names, selected = nil)
    disabled = []
    values  = page_names.map do |page_name|
      model = HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym][:model]
      entry = [I18n.t("activerecord.models.#{ model.tableize.singularize }", :default => model.tableize.singularize.humanize), page_name.to_s]
      
      if !model.constantize.respond_to?(:can_view?)
        disabled << entry# page_name.to_s                                          # TODO  use the commented code to replace +entry+ when upgrading rails to 2.3.2
      end
      
      next unless model.constantize.respond_to?(:can_view?) && model.constantize.can_view?(current_user)
      
      entry
    end
    values.unshift([I18n.t('view.advanced_search.model_select.default'), nil])

    options = options_for_select(values.compact, selected) #{ :selected => selected, :disabled => disabled } )
    
    #TODO  use the commented code to replace +selected+ and the code below when upgrading rails to 2.3.2
    disabled.each {|d| options << content_tag(:option, d.first, :disabled => true, :value => d.last) }
     
    select_tag('p', options, :onchange => "$('page_select_form').submit()")
  end
  
  include EmployeesHelper
end
