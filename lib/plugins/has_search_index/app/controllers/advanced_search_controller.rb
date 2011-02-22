class AdvancedSearchController < ApplicationController
  helper :advanced_search
  
  def index
    @page_names = HasSearchIndex::HTML_PAGES_OPTIONS.keys.select {|key| key.to_s =~ /^advanced_/ }
    
    page_name = if !params[:query_id].blank?
      Query.find(params[:query_id]).page_name
    elsif params[:query] && !params[:query][:page_name].blank?
      params[:query][:page_name]
    elsif !params[:p].blank?
      params[:p]
    end
    
    if page_name
      model = HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym][:model].constantize
      if !model.respond_to?(:can_view?) || !model.can_view?(current_user)
        error_access_page(403) 
      else
        build_query_for(page_name.to_sym) 
      end
    end
    
  end
  
end
