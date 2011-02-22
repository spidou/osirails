module SearchController

  def build_query_for(page_name, page_params = params, *types, &block)
    @page_name = page_name.to_s
    raise Exception, "No query configuration have been found for '#{@page_name}'. You'll find an example of configuration into the file: 'has_search_index/model.example.yml'" unless HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym]
    
    @page_model          = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym][:model]
    @page_configuration  = filter_authorized_options(HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym].clone)
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
    # TODO filter unauthorized columns in saved queries or bloc them if there's unauthorized path in criteria, order, group
    @query ||= Query.new( default_query ? default_query.attributes.reject {|k,v| k =~ /(_at|_id)$/ } : nil )
    
    if page_params[:query]
      [:columns, :order, :search_type].each do |key|
        @query.send("#{ key }=", page_params[:query][key]) if page_params[:query][key]
      end
      @query.group    = page_params[:query][:group]
      @query.per_page = page_params[:query][:per_page].to_i unless page_params[:query][:per_page].blank?
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
    
    # drop column(s) that user can't view
    @query.columns = filter_authorized_columns(@query.columns)
    
    common_options = {
      :object  => @query,
      :locals  => { :page_name => @page_name, :page => page_params[:page] }
    }
    @query_render_options          = common_options.merge(:partial => "shared/filtered_table_container")
    @query_render_options_for_ajax = common_options.merge(:partial => "shared/filtered_table")
    @id_for_ajax_update            = 'integrated_search_table'
    
    if !has_permission_to_search_with?(@query)
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
  
  def filter_authorized_options(page_config)
    [:order, :group, :filters, :columns].each do |option|
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
