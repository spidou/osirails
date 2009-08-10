class SearchIndexesController < ApplicationController
  has_permissions
  
  # GET /index
  def index
    @models      = HasSearchIndex::MODELS.sort
    @main_models = @models.reject {|n| n.constantize.search_index[:main_model] == false}
    @actions     = HasSearchIndex::ACTIONS_TEXT.to_json.to_s 
    @data_types  = HasSearchIndex::ClassMethods::ACTIONS.to_json.to_s
  end
  
  def update
    @params = params # used in view with will paginate
    # get the model where to perform the search
    @model                = ( params[:contextual_search].nil? )? params[:model].constantize : params[:contextual_search][:model].constantize
    @nested_attributes    = []
    criteria              = {}
    @class_to_update = 'search_result'
    
    if @model.search_index[:displayed_attributes].empty?
      @direct_attributes = @model.search_index[:attributes].merge(@model.search_index[:additional_attributes]).keys
    else
      @direct_attributes = @model.search_index[:displayed_attributes]
    end
     
    if !params[:contextual_search].nil?                                             # contextual_search
      searched_value = params[:contextual_search][:value]    
      YAML.load(params[:contextual_search][:options]).each do |attribute|
      model = (attribute.include?("."))? attribute.split(".")[-2].classify.constantize : @model
        if attribute.last == "*"
          attribute = attribute.gsub("*","")
          model.search_index[:attributes].each_key { |att| criteria.merge!(attribute + att => searched_value) }
        else
          criteria.merge!(attribute => searched_value)
        end
      end
      criteria.merge!(:search_type => 'or')
      @class_to_update = 'ajax_holder_content'
    elsif params[:criteria].nil?                                                    # standard search without criteria
      @collection = @model.all  
    else                                                                            # standard search
      params[:criteria].each_value do |criterion|
        attribute = criterion['attribute']
        data_type = criterion['action'].split(",")[0]
        opt_hash  = {:value => @model.format_value(criterion, data_type), :action => criterion['action'].split(",")[1]}
        @direct_attributes << attribute unless attribute.include?(".") or @direct_attributes.include?(attribute)
        @nested_attributes << attribute unless @direct_attributes.include?(attribute)
        if criteria.keys.include?(attribute)
          criteria[attribute] << opt_hash
        else
          criteria.merge!( attribute =>[ opt_hash ] )                                # put the opt_hash into an array to manage multiple attributes 
        end
      end
      criteria.merge!(:search_type => params['search_type'])    
    end  
#    @query = "#{@model.to_s}.search_with(#{criteria.inspect})" 
    @collection = @model.search_with(criteria) unless criteria.empty?
    
    @paginate_collection = @collection.paginate :page => params[:page], :per_page => 15
    
    respond_to do |format|
      format.js   {render :action => "result", :layout => false}
      format.html {render :action => "contextual_search"}
    end
  end
  
end
