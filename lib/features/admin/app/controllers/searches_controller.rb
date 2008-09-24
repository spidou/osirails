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
    
    # test à enlever!!
    @rows = Employee.find(:all)
    
    model = params[:model]['name'].split(",")[1]
    feature = params[:model]['name'].split(",")[0]
    
    section = Feature.find_by_name(feature)
    
    hash = section.search[model]['other'].fusion(section.search[model]['base'])
    
    
    
    # get columns of result array
    section.search[model]['base'].each_pair do |attribute,type|
      if type.class == Hash
        @columns = @columns.fusion(Search.search_result_headers(type))
      else
        @columns << attribute unless @columns.include?(attribute)
      end
    end

    params[:criteria].each_value do |criterion|
      @columns << criterion['attribute'].split(",")[0] unless @columns.include?(criterion['attribute'].split(",")[0]) or criterion['attribute'].split(",")[0].blank?
    end
    
    
    # get attribute url
    @columns.each_with_index do |column,index|
      path = Search.get_attribute_hierarchie(hash,column)
      # modify the last value to pick out the "_"
      path[path.index(path.last)] = column
      @columns[index] = path
    end
    
    flash.now[:notice]= params.inspect
    @searches = {}
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
    end
  end
  
end
