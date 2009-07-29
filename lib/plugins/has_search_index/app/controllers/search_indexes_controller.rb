class SearchIndexesController < ApplicationController
  has_permissions
  
  # GET /index
  def index
    @models = HasSearchIndex::MODELS.sort
    @main_models = @models.reject {|n| n.constantize.search_index[:main_model] == false}
    @actions = HasSearchIndex::ACTIONS_TEXT.to_json.to_s 
    @data_types = HasSearchIndex::ClassMethods::ACTIONS.to_json.to_s
  end
  
  def update
    # get the model where to perform the search
    @model = (params[:contextual_search].nil? )? params[:model].constantize : params[:contextual_search][:model].constantize
    
    if @model.search_index[:displayed_attributes].empty?
      @columns = @model.search_index[:attributes].merge(@model.search_index[:additional_attributes]).keys
    else
      @columns = @model.search_index[:displayed_attributes] 
    end
    
    if params[:contextual_search].nil?                                              # standard search
      criteria = {}
      @criteria = params[:criteria].values
      
      params[:criteria].each_value do |criterion|
        attribute = criterion['attribute']
        opt_hash = {:value => @model.format_value(criterion), :action => criterion['action'].split(",")[1]}
        if criteria.keys.include?(attribute)
          criteria[attribute] << opt_hash
        else
          criteria = criteria.merge( {attribute =>[ opt_hash ]} )                   # put the opt_hash into an array to permit management of mutiple values to an attribute 
        end
      end
      @query = @model.to_s + ".search_with(" + criteria.merge(:search_type => params['search_type']).inspect + ")" # Optimize delete that if not needed for debuging
      @collection = @model.search_with(criteria.merge(:search_type => params['search_type']))
    else                                                                            # contextual_search
      options = YAML.load(params[:contextual_search][:options])
      searched_value = params[:contextual_search][:value]
      @query = "#{@model.to_s}.search_with('#{searched_value}',#{options.inspect})" # Optimize delete that if not needed for debuging
      @collection = @model.search_with(searched_value, options)
    end  
    
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
      format.html {render :action => "contextual_search"}
    end
  end
  
end
