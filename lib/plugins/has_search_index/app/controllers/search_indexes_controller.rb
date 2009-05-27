class SearchIndexesController < ApplicationController
  has_permissions
  
  # GET /index
  def index 
    @models = HasSearchIndex::MODELS.sort
  end
  
  def update
    criteria = {}
    @model = params[:model].constantize
    if @model.search_index[:displayed_attributes].empty?
      @columns = @model.search_index[:attributes].merge(@model.search_index[:additional_attributes]).keys
    else
      @columns = @model.search_index[:displayed_attributes] 
    end

    params[:criteria].each_value do |criterion|
      attribute = criterion['attribute'].split(",")[1]
      opt_hash = {:value => @model.format_value( criterion ), :action => criterion['action']}
      if criteria.keys.include?(attribute)
        criteria[attribute] << opt_hash
      else
        criteria = criteria.merge( {attribute =>[ opt_hash ]} )                   # put the opt_hash into an array to permit management of mutiple values to an attribute 
      end
    end
    @query = @model.to_s + ".search_with(" + criteria.merge(:search_type => params['search_type']).inspect + ")"
    @collection = @model.search_with(criteria.merge(:search_type => params['search_type']))
    
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
      format.html {render :action => "result"}
    end
    
  end
  
end
