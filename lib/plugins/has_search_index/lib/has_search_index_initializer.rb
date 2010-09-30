# add some methods to ApplicationController
#
module IntegratedSearchApplicationController

  def build_query_for(page_name, page_params = params, *types, &block)
    @page_name           = page_name.to_s
    @page_configuration  = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym].clone
    default_query        = @page_configuration[:default_query]
    @organized_filters ||= HasSearchIndex.organized_filters(@page_configuration[:filters], @page_configuration[:model])
    @can_be_cancelled    = page_params.keys.include_any?(['query', 'per_page', 'order_column', 'criteria'])
    @can_quick_search    = @page_configuration[:quick_search].any?
    
    @data_types = { @page_name => {} }
    @page_configuration[:filters].each do |filter|
      attribute = filter.is_a?(Hash) ? filter.values.first : filter
      @data_types[@page_name][attribute] = HasSearchIndex.get_nested_attribute_type(@page_configuration[:model], filter)
    end
    
    @query = Query.find(page_params[:query_id]) unless page_params[:query_id].blank? rescue nil
    @query ||= Query.new( default_query ? default_query.attributes.reject {|k,v| k =~ /(_at|_id)$/ } : nil )
    
    if page_params[:query]
      [:columns, :group, :search_type, :per_page, :order].each do |key|
        @query.send("#{ key }=", page_params[:query][key])
      end
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
      @query.per_page = (page_params[:per_page] == 'all' ? nil : page_params[:per_page])
    end
    
    if page_params[:order_column]
      order = @query.order.dup
      order.delete_if {|n| HasSearchIndex.get_order_attribute(n) == HasSearchIndex.get_order_attribute(page_params[:order_column])}
      order.unshift(page_params[:order_column])
      @query.order = order
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
    
    if page_params[:key_word]
      @query.quick_search_value = page_params[:key_word] unless page_params[:key_word].blank?
    end
    
    @class_for_ajax_update = 'integrated_search'
    @query_render_options  = { 
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
          format.js { render( @query_render_options ) }
          format.html
        end.call(format)
      end
    end
    
  end
end

# Set it all up.
if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, IntegratedSearchApplicationController)
  ActionController::Base.send(:helper, :integrated_search)
end
