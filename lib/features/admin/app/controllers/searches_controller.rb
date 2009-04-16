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
    
    # determine if its a standard search or contextual search
    if params[:contextual_search].nil? # standard search
    
      unless params[:model]['name'].blank?
      
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
        
        # make params[:criteria] nil if there is only one blank attribute
        unless params[:criteria].nil?
          # return no result if there is no attribute or blank attribute
          params.delete("criteria") if params[:criteria].size==1 and params[:criteria][params[:criteria].keys[0]]['attribute'].blank?
        end
        
        unless params[:criteria].nil? 
          
          params[:criteria].each_value do |criterion|
            @columns << [criterion['parent'], criterion['attribute'].split(",")[0]] unless @columns.include?([criterion['parent'],criterion['attribute'].split(",")[0]]) or criterion['attribute'].split(",")[0].blank?
          end

          # get attribute url
          @columns.each_with_index do |column,index|
            path = Search.get_attribute_hierarchy(hash,column[1],column[0],model)
          # modify the last value to pick out the "_"
            path[path.index(path.last)] = column[1]
            @columns[index] = path
          end
          # group sub attributes
          @columns = Search.group(@columns)
          
          @rows = model.constantize.find(:all, :include => Search.get_include_hash(section.search[model]), :conditions => Search.get_conditions_array(params[:criteria],model,params[:search_type]) )

        end
      end
      
    else # contextual search
      model = params[:contextual_search]['model']
      @value = params[:contextual_search]['value']
      unless Search.get_feature(model) == [] 
        attributes = Search.get_feature(model)[1]
        
        attributes = attributes['other'].fusion(attributes['base']) if attributes.keys.include?('other')  
        
        section = Feature.find_by_name(Search.get_feature(model)[0])
        
        params[:criteria]={}
        i=0
        attributes.each_pair do |attribute,type|
          params[:criteria][i.to_s] = {:action => 'like',:attribute => attribute,:value => @value,:parent => model} unless type.class == Hash
          @columns << [attribute] unless type.class == Hash
          i+=1
        end
        @model = model
        @rows = model.constantize.find(:all, :include => Search.get_include_hash(section.search[model]), :conditions => Search.get_conditions_array(params[:criteria],model,'or') )

      else
        @error = "fichier de configuration absent ou incomplet pour le module #{model}"
      end  
    end  
    @searches = {}
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
      format.html {render :action => "result"}
    end
  end
  
end
