module HasSearchIndex
  require 'yaml'
  
  def self.define_html_pages_options_for(page_name, options, error_prefix)
    page_options  = HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym] || {}
    default_query = options.delete(:default_query)
    page_options.merge!(options)
    page_options[:default_query] ||= default_query
    
    if page_options[:default_query]
      default_query.attributes.each { |method, value| page_options[:default_query].send("#{ method }=", value) } if default_query
      page_options[:default_query].order ||= []
      page_options[:default_query].group ||= []
      page_options[:default_query].columns = page_options[:columns] if (page_options[:default_query].columns || []).empty?
    end
    
    
    
    # Manage here default values permit to merge keeping old values (keys that are not overriden have nil value)
    [:filters, :group, :order, :per_page, :columns].each do |option|
      page_options[option] ||= []
    end
    
    message = "#{ error_prefix } Mandatory key ':columns'"
    raise ArgumentError, message if page_options[:columns].empty?
    
    HasSearchIndex::HTML_PAGES_OPTIONS[page_name.to_sym] = page_options
  end
  
  ## Method to check Yaml options file according to HasSearchIndex implementation
  #
  # +options+ permit to pass options loaded by your self and to skip yml_path loading (that mean that you perfom the load before calling that method)
  #                 
  def self.load_page_options_from(yml_path, options = nil)
    error_prefix   = "(has_search_index) in (#{ yml_path }) >"
    model          = yml_path.split('/').last.gsub('.yml','').camelize
    
    message  = "#{ error_prefix } Wrong filename '#{ model.to_s.downcase }.yml'. '#{ model }' should be a valid model"
    message += " and should implement 'has_search_index' plugin "
    raise ArgumentError, message unless MODELS.include?(model)
    
    options ||= YAML.load_file(yml_path).reject {|page_name, v| page_name =~ /^conf_/ } ## load options from yaml unless options are passed as argument
    model     = model.constantize
    
    options.each_pair do |page_name, page_options|
      error_prefix = "#{ error_prefix } #{ page_name }:"
      page         = { :default_query => nil }
      
      # Check :per_page (pagination option)
      if page_options.include?('per_page') && page_options['per_page']
        message = "#{ error_prefix } :per_page should be an Array of Integer"
        raise ArgumentError, message unless page_options['per_page'].is_a?(Array) && page_options['per_page'].reject{ |n| n.is_a?(Integer) }.empty?
        page[:per_page] = page_options['per_page']
      end
      
      # Check default_query
      if page_options.include?('default_query') && page_options['default_query']
        error_prefix = "#{ error_prefix } > default_query:"
        page[:default_query] = Query.new(:public_access => true, :criteria => {}, :page_name => page_name)
        [:columns, :group].each do |key|
          page[:default_query].send("#{ key }=", check_page_option(key.to_s, page_options['default_query'], model, error_prefix))
        end
        page[:default_query].order    = check_page_option_order(page_options['default_query'], model, error_prefix)
        page[:default_query].per_page = page_options['default_query']['per_page'].to_i if page_options['default_query']['per_page']  # TODO test that line
        
        # Check default_query's criteria
        unless (criteria = model.check_criteria(page_options['default_query']['criteria'])).nil?
          criteria.each do |key, value|
            value.symbolize_keys! if value.is_a?(Hash)
            value.collect!(&:symbolize_keys!) if value.is_a?(Array)
            page[:default_query].criteria.merge!(key => value)
          end
        end
      end
      
      # Check ATTRIBUTE_PATHs of Keys [:columns, :group, :order]
      [:columns, :group, :order].each do |key|
        page[key] = check_page_option(key.to_s, page_options, model, error_prefix)
      end
      page[:filters] = check_page_option_filters(page_options, model, error_prefix)
      
      # Save the model where the search will be performed
      page[:model] = model.to_s
      
      define_html_pages_options_for(page_name, page, error_prefix)
    end
  end
  
  def self.get_order_attribute(element)
    element.to_s.split(':').first.strip.downcase
  end
  
  def self.get_order_direction(element)
    (element.to_s.split(':').at(1) || 'asc').strip.downcase   # use at(1) instead of .last because without ':' the first will also be the last
  end  
  
  # Method to get a hierachical collection of attributes and relationships from configured filters
  #
  def self.organized_filters(elements, model, group = '')
    elements.group_by do |n|
      n.rchomp(group).split('.').first if !n.is_a?(Hash) && n.rchomp(group).include?('.')
    end.map {|n| n.first.nil? ? n : [n.first, organized_filters(n.last, model, "#{ group }#{ n.first }.")]}
  end
  
  # Method to get attribute type even if it is nested
  #
  def self.get_nested_attribute_type(model, attribute)
    relationship   = model.constantize
    result         = nil
    attribute_path = attribute.is_a?(Hash) ? attribute.values.first : attribute
    attribute_path.split('.').each do |part|
      class_name = relationship.reflect_on_association(part.to_sym) && relationship.reflect_on_association(part.to_sym).class_name
      unless class_name.nil?
        relationship = class_name.constantize
      else
        result = relationship.search_index_attribute_type(part)
      end
    end
    return result
  end
  
  private
  
    def self.check_value_is_an_array(value, error_prefix)
      message = "#{ error_prefix } Expected to be an Array but was sort of #{ value.class }"
      raise ArgumentError, message unless value.is_a?(Array)
    end
    
    ## Method to check a page option in (:columns, :group)
    #
    def self.check_page_option(key, page_options, model, error_prefix)
      return nil unless page_options.keys.include?(key)
      page_options[key] ||= []
      check_value_is_an_array(page_options[key], error_prefix + "Wrong key ':#{ key }'.")
      page_options[key].map do |attribute|
        check_page_attribute(attribute.to_s, model, error_prefix, allow_collection = false)
      end.flatten
    end
    
    # Method to check filters
    #
    def self.check_page_option_filters(page_options, model, error_prefix)
      return nil unless page_options.keys.include?('filters')
      page_options['filters'] ||= []
      check_value_is_an_array(page_options['filters'], error_prefix + "Wrong key ':filters'.")
      page_options['filters'].map do |attribute|
        message = "#{ error_prefix } Wrong attribute '#{ attribute.inspect }'. Expected to be a Hash or a String but was sort of #{ attribute.class }"
        raise(ArgumentError, message) unless attribute.is_a?(String) || attribute.is_a?(Hash)
        
        check_page_attribute(attribute, model, error_prefix)
      end.flatten
    end
    
    def self.check_page_option_order(page_options, model, error_prefix)
      return nil unless page_options.keys.include?('order')
      page_options['order'] ||= []
      check_value_is_an_array(page_options['order'], error_prefix + "Wrong key ':order'.")
      page_options['order'].map do |option|
        direction = get_order_direction(option)
        message   = "#{ error_prefix } Wrong direction '#{ direction }'. Expected to be in ('Desc', 'Asc', nil)"
        raise(ArgumentError, message) unless ['desc', 'asc'].include?(direction)
        
        check_page_attribute(get_order_attribute(option), model, error_prefix, allow_collection = false).map do |attribute|
          "#{ attribute }:#{ direction }"
        end
      end.flatten
    end
    
    ## Method to check page attribute
    # Return the attribute or a collection of attribute if the attribute include? '*'
    #
    # === example
    #
    # numbers.* 
    # => return:Array Number.search_index_attributes.keys
    # numbers.number 
    # => return:Array ["number.number"] if each part of the attribute is valid
    #
    def self.check_page_attribute(attribute, model, error_prefix, allow_collection = true)
      splitted_attribute = (attribute.is_a?(Hash) ? attribute.values.first.split('.') : attribute.split('.'))
      splitted_attribute.each do |part|
        message = "#{ error_prefix } '#{ part }' in '#{ splitted_attribute.join('.') }' is not defined for 'has_search_index' into '#{ model }' model"
        if part == splitted_attribute.last
          if part == '*'
            raise ArgumentError, "#{ error_prefix } you can't use globbing (*) while using alias for a filter (#{ attribute.inspect })" if attribute.is_a?(Hash)
            return model.search_index_attributes.keys.collect {|attr| splitted_attribute.join('.').gsub('*', attr) }
          end
          raise(ArgumentError, message) unless model.search_index_attributes.keys.include?(part)
        else
          raise(ArgumentError, message) unless model.search_index_relationships.include?(part.to_sym)
          
          if !allow_collection && [:has_many, :has_and_belongs_to_many].include?(model.reflect_on_association(part.to_sym).macro)
            message  = "#{ error_prefix } '#{ part }' in '#{ splitted_attribute.join('.') }' is wrong."
            message += " Relationships that return collection are not allowed for (:order, :group, :columns)"
            raise(ArgumentError, message)
          end
          
          model   = model.reflect_on_association(part.to_sym).class_name.constantize
          message = "#{ error_prefix } model '#{ model }' should implements 'has_search_index' plugin in order to use it."
          raise message unless MODELS.include?(model.to_s)
        end
      end
      
      return [attribute]
    end

end
