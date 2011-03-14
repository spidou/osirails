class AdvancedSearchController < ApplicationController
  helper :advanced_search
  query :all
  
  def index
    @page_names = HasSearchIndex::HTML_PAGES_OPTIONS.keys.select {|key| key.to_s =~ /^advanced_/ }
    
    page_name = page_name_from(params)
    
    if page_name
      model = HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym][:model].constantize
      if !model.respond_to?(:can_view?) || !model.can_view?(current_user)
        error_access_page(403) 
      else
        build_query_for(page_name.to_sym) 
      end
    end
  end
  
  private
  
    def page_name_from(var)
      if !var[:query_id].blank?
        Query.find(params[:query_id]).page_name
      elsif var[:query] && !var[:query][:page_name].blank?
        var[:query][:page_name]
      elsif !var[:p].blank?
        var[:p]
      end
    end
  
end
