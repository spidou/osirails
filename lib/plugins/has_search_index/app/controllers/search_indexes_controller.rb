class SearchIndexesController < ApplicationController
  include HasSearchIndexMethodsHelper
  
  # GET /index
  def index
    @models      = HasSearchIndex::MODELS.sort
    @main_models = @models.reject {|n| n.constantize.search_index[:main_model] == false}
    @actions     = HasSearchIndex::ACTIONS_TEXT.to_json.to_s 
    @data_types  = HasSearchIndex::ClassMethods::ACTIONS.to_json.to_s
  end
  
  def update
    @nested_attributes = []
    @direct_attributes = []
    @params            = params # used in view with will paginate
    model              = main_model(params)
    
    unless model.nil?
      if model.search_index[:displayed_attributes].empty?
        @direct_attributes = model.search_index[:attributes].merge(model.search_index[:additional_attributes]).keys
      else
        @direct_attributes = model.search_index[:displayed_attributes]
      end
    end
    
    if contextual_search?(params)
      @class_to_update = 'ajax_holder_content'
      criteria = prepare_criteria_for_contextual_search(params)
    else
      unless params[:criteria].nil? 
        params[:criteria].each_value do |criterion|
          attribute = criterion['attribute'].downcase
          @direct_attributes << attribute unless attribute.include?(".") or @direct_attributes.include?(attribute)
          @nested_attributes << attribute unless @direct_attributes.include?(attribute)
        end
      end
      @class_to_update = 'search_result'
      criteria = prepare_criteria_for_search(params)
    end
    
#    @query = "#{model.to_s}.search_with(#{criteria.inspect})"
    @items = search(model, criteria).paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.js   {render :action => "result", :layout => false}
      format.html {render :action => "result"}
    end
  end
  
end
