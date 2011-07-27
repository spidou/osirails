module SearchController

  def build_query_for(page_name, page_params = params, *types, &block)
    @page_name = page_name.to_s
    raise Exception, "No query configuration have been found for '#{@page_name}'. You'll find an example of configuration into the file: 'has_search_index/model.example.yml'" unless HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym]
    
    @page_model          = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym][:model]
    @page_configuration  = filter_authorized_options(HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym].dup)
    default_query        = @page_configuration[:default_query] ? @page_configuration[:default_query].attributes.symbolize_keys : {}
    @organized_filters ||= HasSearchIndex.organized_filters(@page_configuration[:filters], @page_model)
    @can_be_cancelled    = page_params.keys.include_any?(['query', 'per_page', 'order_column', 'criteria', 'keyword'])
    @can_quick_search    = @page_configuration[:quick_search].any?
    
    @data_types = { @page_name => {} }
    @page_configuration[:filters].each do |filter|
      attribute = filter.is_a?(Hash) ? filter.values.first : filter
      @data_types[@page_name][attribute] = HasSearchIndex.get_nested_attribute_type(@page_model, filter)
    end
    
    @query             ||= get_query_from(page_params, default_query)
    @query.columns     ||= default_query['columns'] || @page_configuration[:columns]
    @query.group       ||= []
    @query.order       ||= []
    @query.criteria    ||= {}
    @query.search_type ||= 'and'
    @query.page_name     = @page_name
    @query.public_access = true if @query.public_access.nil?
    @query.quick_search_value ||= nil
    
    # filter Query to suite permissions
    @query.columns      = filter_authorized_columns(@query.columns)
    @query.option_cache = @page_configuration.dup
    
    common_options = {
      :object  => @query,
      :locals  => { :page_name => @page_name, :page => page_params[:page] }
    }
    @query_render_options          = common_options.merge(:partial => "shared/filtered_table_container")
    @query_render_options_for_ajax = common_options.merge(:partial => "shared/filtered_table")
    @id_for_ajax_update            = 'integrated_search_table'
    
    if @page_configuration[:columns].empty? || @query.columns.empty? || !has_permission_to_search_with?(@query)
      respond_to do |format|
        format.js { render(:text => "<div class='search_no_result'>#{ I18n.t('view.forbidden_options') }</div>") }
        format.html { error_access_page(403) }
      end
    elsif types.any?
      respond_to(types)
    else
      respond_to do |format|
        lambda do |f|
          yield(f) if block_given?
          format.js { render(@query_render_options_for_ajax) }
          format.html
        end.call(format)
      end
    end
    
  end
end

private 
  
  def get_query_from(params, default_query)
    
    query   = Query.find(params[:query_id]) unless params[:query_id].blank? rescue nil
    query ||= Query.new(default_query.reject {|k,v| k.to_s =~ /(_at|_id)$/ })
    
    if params[:query]
      [:columns, :order, :search_type, :group].each do |key|
        query.send("#{ key }=", params[:query][key])
      end
      query.per_page = params[:query][:per_page].to_i unless params[:query][:per_page].blank?
    end

    if params[:per_page]
      query.per_page = (params[:per_page] == 'all' ? nil : params[:per_page].to_i)
    end
    
    if params[:criteria_loaded]
      params[:criteria] ||= {}
      query.criteria = {}  ## empty criteria to take only user choice
      
      params[:criteria].each do |attribute, options|
        options[:value].each_with_index do |value, index|
          (query.criteria[attribute] ||= []) << {:action => options[:action].at(index), :value => value}
        end
      end
    end
    
    if params[:keyword]
      query.quick_search_value = params[:keyword] unless params[:keyword].blank?
    end
  
    if params[:order_column]
      query.order = params[:order] || []
      query.order.delete_if {|n| HasSearchIndex.get_order_attribute(n) == HasSearchIndex.get_order_attribute(params[:order_column])}
      query.order.unshift(params[:order_column]) unless params[:order_column].match(/:no_sort$/)
    end
    
    query
  end
  
  # Method to filter option according to permisions
  #
  def filter_authorized_options(page_config)
    [:order, :group, :filters, :columns, :quick_search].each do |option|
      page_config[option] = page_config[option].select {|attribute| user_can_view?(get_attribute_path(attribute))} if page_config[option]
    end
    
    page_config
  end
  
  # attribute can be "path" or {:alias => "path"} ( only for filters )
  #
  def get_attribute_path(attribute)
    attribute.is_a?(Hash) ? attribute.values.first : attribute
  end
  
  def filter_authorized_columns(columns)
    columns.select { |column| user_can_view?(column) }
  end

  def has_permission_to_search_with?(query)
    [:group, :order].each do |key|
        return false if query.send(key).reject {|attribute| user_can_view?(attribute)}.any?
    end
    query.criteria.each do |attribute, option|
      return false if !user_can_view?(attribute)
    end
    
    true
  end

  def user_can_view?(path)
    return true unless path.include?('.')
    
    while(path.include?('.'))
      attribute = path.split('.').pop
      path      = path.chomp(".#{ attribute }")
      model     = @page_model.constantize.search_index_relationship_class_name(path).constantize
      
      return model.can_view?(current_user) if model.respond_to?(:can_view?)
    end
    
    return true
  end

# Set it all up.
if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, SearchController)
end
