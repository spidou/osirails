class SearchesController < ApplicationController
  
  def index
    @searches = {}
    Feature.find(:all).each do |feature|
      unless feature.search.nil?
          @searches = @searches.merge({feature.name => feature.search.keys})
      end  
    end
  end
  
  def update
    
    @columns ||= []
    @rows ||=[]
    
    # TODO l18 = test à enlever!!
    @rows = Employee.find(:all)
    
    model = params[:model]['name'].split(",")[1]
    feature = params[:model]['name'].split(",")[0]
    
    section = Feature.find_by_name(feature)
    
    hash = section.search[model]['other'].fusion(section.search[model]['base'])
    
    
    
    # get columns of result array
    section.search[model]['base'].each_pair do |attribute,type|
      if type.class == Hash
        @columns = @columns.fusion(Search.search_result_headers(type,model))
      else
        @columns << [model, attribute] unless @columns.include?([model,attribute])
      end
    end

    params[:criteria].each_value do |criterion|
      @columns << [criterion['parent'], criterion['attribute'].split(",")[0]] unless @columns.include?([criterion['parent'],criterion['attribute'].split(",")[0]]) or criterion['attribute'].split(",")[0].blank?
    end
    # get attribute url
    @columns.each_with_index do |column,index|
      path = Search.get_attribute_hierarchy(hash,column[1],column[0])
      # modify the last value to pick out the "_"
      path[path.index(path.last)] = column[1]
      @columns[index] = path
    end

    @rows = model.constantize.find(:all, :include => Search.get_include_hash(section.search), :conditions => Search.get_conditions_array(params[:criteria],model) )
    @searches = {}
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
    end
  end
  
end
