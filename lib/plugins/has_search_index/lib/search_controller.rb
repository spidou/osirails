module SearchController

  def build_query_for(page_name, page_params = params, *types, &block)
    @page_name = page_name.to_s
    raise Exception, "No query configuration have been found for '#{@page_name}'. You'll find an example of configuration into the file: 'has_search_index/model.example.yml'" unless HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym]
    
    @page_configuration  = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym].clone
    @page_model          = @page_configuration[:model]
    default_query        = @page_configuration[:default_query]
    @organized_filters ||= HasSearchIndex.organized_filters(@page_configuration[:filters], @page_model)
    @can_be_cancelled    = page_params.keys.include_any?(['query', 'per_page', 'order_column', 'criteria'])
    @can_quick_search    = @page_configuration[:quick_search].any?
    
    @data_types = { @page_name => {} }
    @page_configuration[:filters].each do |filter|
      attribute = filter.is_a?(Hash) ? filter.values.first : filter
      @data_types[@page_name][attribute] = HasSearchIndex.get_nested_attribute_type(@page_model, filter)
    end
    
    @query = Query.find(page_params[:query_id]) unless page_params[:query_id].blank? rescue nil
    @query ||= Query.new( default_query ? default_query.attributes.reject {|k,v| k =~ /(_at|_id)$/ } : nil )
    
    if page_params[:query]
      [:columns, :group, :search_type, :order].each do |key|
        @query.send("#{ key }=", page_params[:query][key]) unless page_params[:query][key].nil?
      end
      @query.per_page = page_params[:query][:per_page].to_i if page_params[:query][:per_page]
    end
    
    @query.columns     ||= default_query ? default_query.columns : @page_configuration[:columns]
    @query.group       ||= []
    @query.order       ||= []
    @query.criteria    ||= {}
    @query.search_type ||= 'and'
    @query.page_name     = @page_name
    @query.public_access = true if @query.public_access.nil?
    @query.quick_search_value = nil    
    
    if page_params[:per_page]
      @query.per_page = (page_params[:per_page] == 'all' ? nil : page_params[:per_page].to_i)
    end
    
    if @can_be_cancelled
      @query.criteria = {}
      if page_params[:criteria]
        page_params[:criteria].each do |attribute, options|
          options[:value].each_with_index do |value, index|
            (@query.criteria[attribute] ||= []) << {:action => options[:action].at(index), :value => value}
          end
        end
      end
    end
    
    if page_params[:keyword]
      @query.quick_search_value = page_params[:keyword] unless page_params[:keyword].blank?
    end
  
    if page_params[:order_column]
      order = @query.order.dup
      order.delete_if {|n| HasSearchIndex.get_order_attribute(n) == HasSearchIndex.get_order_attribute(page_params[:order_column])}
      order.unshift(page_params[:order_column]) unless page_params[:order_column].match(/:no_sort$/)
      
      @query.order = order
    end
    
    @id_for_ajax_update = 'integrated_search_table'
#    @class_for_ajax_update = 'integrated_search'
    @query_render_options  = { 
      :partial => "shared/filtered_table_container",
      :object => @query,
      :locals => { :page_name => @page_name, :page => page_params[:page] }
    }
    
    #@query_render_options_for_ajax = @query_render_options.merge({ :partial => "shared/filtered_table" })
    @query_render_options_for_ajax = { 
      :partial => "shared/filtered_table",
      :object => @query,
      :locals => { :page_name => @page_name, :page => page_params[:page] }
    }
    
    if types.any?
      respond_to(types)
    else
      respond_to do |format|
        lambda do |f|
          yield(f) if block_given?
          format.js { render( @query_render_options_for_ajax ) }
          format.html
        end.call(format)
      end
    end
    
  end
end

# Set it all up.
if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, SearchController)
end
