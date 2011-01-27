module IntegratedSearchHelper

  def apply_query_link
    options = {
      :url => url_for,
      :method => :get,
      :before => "validSelectOptions('group columns');",
      :update => @class_for_ajax_update,
      :with => "Form.serialize('query_form')"
    }
    link_to_remote(I18n.t('link.apply.name'),
      options,
      :title => I18n.t('link.apply.title'),
      :class => 'apply')
  end
  
  def new_query_link
    link_to(I18n.t('link.new.name'), {},
      :title   => I18n.t('link.new.title'),
      :onclick => "submitFormFor('new'); return false;")
  end
  
  def edit_query_link(query)
    link_to(I18n.t('link.edit.name'), {},
      :title => I18n.t('link.edit.title'),
      :onclick => "submitFormFor('#{ query.id }/edit'); return false;")
  end
  
  def delete_query_link(query)
    link_to(I18n.t('link.delete.name'),
      query_path(query, :return_uri => url_for),
      :title => I18n.t('link.delete.title'),
      :method => :delete,
      :confirm => 'Êtes vous sûr?')
  end
  
  def reset_query_link(query)
    page_name  = (params[:query] && params[:query][:page_name]) || params[:p]
    parameters = []
    parameters << "query_id=#{ query.id }" if query.id
    parameters << "p=#{ page_name }" if page_name
    remote_options = {
      :url => url_for,
      :method => :get,
      :update => @class_for_ajax_update,
      :with => "'#{ parameters.join('&') }'"
    }
    
    content_tag(:div, :class => 'cancel_link') do
      link_to_remote("#{ I18n.t('link.reset.name') }",
        remote_options,
        :title => I18n.t('link.reset.title'),
        :class => 'reset_query_link',
        :style => "#{ 'display:none' unless @can_be_cancelled }"
      )
    end
  end
  
  def toggle_form_link(visible = true)
    quick_search_visible_class = should_render_quick_search? && !visible ? 'quick_search_visible' : ''
    
    link = content_tag(
      :span, nil,
      :onclick => "toggleIntegratedForm('#{ @page_name }', this)",
      :class   => "toggle_integrated_form #{quick_search_visible_class}",
      :title   => I18n.t('link.toggle.title')
    )
                       
    content_tag(:div, :class => 'toggle_link') do
      content_tag(:span, :class => "quick_search") { [link, quick_search(!visible)] }
    end
  end
  
  def quick_search(visible = true)
    return unless should_render_quick_search?
    
    restore_value = I18n.t('view.quick_search.default')
    visible_class = visible ? '' : 'hidden'
    
    submit_function = remote_function({
      :url      => params.reject{ |k,v| k.to_s == 'keyword' },
      :method   => :get,
      :update   => @class_for_ajax_update,
      :with     => "'keyword=' + escape(this.up().down('INPUT').value)",
      :complete => "$('quick_input').focus(); $('quick_input').selectionStart = $('quick_input').selectionEnd;"
    })
  
    content  = text_field_tag(nil, @query.quick_search_value || restore_value,
                                   :onkeypress   => "if(event.which == Event.KEY_RETURN){ #{ submit_function }; return false }",
                                   :id           => "quick_input",
                                   :restoreValue => restore_value,
                                   :style        => @query.quick_search_value ? '' : 'color: grey; font-style: italic;',
                                   :onfocus      => "if (this.value == this.getAttribute('restoreValue')) { this.value=''; this.style.color='inherit'; this.style.fontStyle='inherit' } else { select() }",
                                   :onblur       => "if (this.value == '' || this.value == this.getAttribute('restoreValue')) { this.value = this.getAttribute('restoreValue'); this.style.color='grey'; this.style.fontStyle='italic' } else { this.selectionStart = 0 }")
    content += link_to_function(nil, submit_function, :title => I18n.t('view.quick_search.title'))
    
    content_tag(:div, content, :class => "quick_search_inputs #{visible_class}")
  end
  
  def links(query)
    links  = [apply_query_link, new_query_link]
    links += [edit_query_link(query), delete_query_link(query)] if (!query.new_record? && query.creator == current_user)
    content_tag(:div, links.join, :class => "public_links")
  end
  
  def add_order_link(page_config)
    message = I18n.t('link.add_order.title')
    link_to_function(image_tag("add_16x16.png", :alt => message, :title => message)) do |page|
      partial = escape_javascript(render(:partial => "shared/order_option",
                                         :locals => {:page_config => page_config} ))
      page << h("this.parentNode.previous().insert({bottom: '#{ partial }'})")
    end
  end
  
  def paginate_per_page(query)
    per_pages = HasSearchIndex::HTML_PAGES_OPTIONS[query.page_name.to_sym][:per_page] + [ nil ]
    
    content_tag(:div, :class => 'pagination per_pages') do
      [content_tag(:span, "#{ I18n.t('view.paginate_per_page') } : ")] + per_pages.map do |per_page|
        query.per_page.to_s == per_page.to_s ? content_tag(:span, paginate_text(per_page), :class => 'current') : content_tag(:span, paginate_link(per_page))
      end
    end
  end

  
  # Method to prepare collection to be used with 'options_for_select'
  # 
  def prepare_for_options(collection)
    collection.map{ |n| n && [humanize(n), n] }
  end
  
  # Method to create a link permitting to modify pagination option with Ajax
  #
  def paginate_link(per_page)
    link_to_remote(paginate_text(per_page),
      :update => @class_for_ajax_update,
      :method => :get,
      :url => params.merge(:per_page => per_page || 'all'))
  end
  
  def paginate_text(per_page)
    per_page ? per_page.to_s : I18n.t("view.paginate_all")
  end
  
  def toggle_options_legend(collapse = true)
    content_tag(:legend, 
      I18n.t("link.toggle_options.name"),
      :title => I18n.t("link.toggle_options.title"),
      :class => collapse ? 'collapsed' : 'not-collapsed',
      :onclick => "toggleOptionsFieldset('#{ @page_name }', this);")
  end
  
  def toggle_criteria_legend(collapse = false)
    content_tag(:legend, 
      I18n.t("link.toggle_criteria.name"),
      :title => I18n.t("link.toggle_criteria.title"),
      :class => collapse ? 'collapsed' : 'not-collapsed',
      :onclick => "toggleCriteriaFieldset('#{ @page_name }', this);")
  end
  
  def page_default_name
    I18n.t("integrated_search.page_names.#{ @query.subject_model.underscore }.#{ @page_name }", :default => @page_name)
  end
  
  def title_for_search
    (@query.name || page_default_name).humanize
  end
  
  def table_for_search
    saved_queries = Query.all(:conditions => ["page_name = ? and name != ? and (creator_id = ? or public_access = ?)",
                                              @page_name, @query.name||'', current_user.id, true])
    
    if @query.name
      add_contextual_menu_item(:personalized_queries) do 
        link_to(page_default_name.humanize, { :p => @page_name }, 'data-icon' => :index)
      end
    end
    
    saved_queries.each do |saved_query|
      add_contextual_menu_item(:personalized_queries) do
        link_to(saved_query.name, { :query_id => saved_query.id }, 'data-icon' => :index)
      end
    end
    
    render(@query_render_options) # @query_render_options is defined in has_search_index_initializer.rb
  end
  
  #################################################################
  ################## Methods to generate table ####################
  
  # Method to generate table form query
  #
  def generate_table(query, page)
    @helper_end_with_page_name = "_in_#{ query.page_name }"
    @helper_end_with_model = "_in_#{ query.subject_model.underscore }"
    header  = generate_table_header(query)
    records = records_with_or_without_paginate(query, page)
    body    = generate_table_body(records, query.columns, query.group)
    table   = query_table("#{ header }#{ body }")
    pagination = generate_pagination(records, query)
    
    records.empty? ? content_tag(:div, I18n.t("view.no_result"), :class => 'search_no_result') : "#{ table }#{ pagination }"
  end
  
  # Method to generate pagination links
  #
  def generate_pagination(records, query)
    options = {
      :renderer               => 'RemoteLinkRenderer',
      :method_for_remote_link => :get,
      :remote                 => { :update => @class_for_ajax_update }
    }
    
    content_tag :div, :class => :pagination_container do
      "#{ will_paginate(records, options) if with_paginate?(query) } #{ paginate_per_page(query) }"
    end
  end
  
  # Methods to generate header from columns
  ## Take in account actions columns
  #
  def generate_table_header(query)
    query_thead(query.columns.map{ |column| query_th(column, query.order) }.join)
  end
  
  # Methods to generate a table body from a query
  #
  def generate_table_body(records, columns, group)
    content = if group && group.any?
      generate_grouped_table_rows(records, columns, group)
    else
      query_tbody(records.map{ |record| generate_table_row(record, columns) }.join)
    end
  
    content
  end
  
  # Method to generate grouped rows with records
  # group_list is an Array of group wich will permit to group with nested levels
  ## Take in account actions columns
  #
  def generate_grouped_table_rows(records, columns, group_list)
    grouped_records(records, group_list).map do |group|
      group_by = group.first
      #TODO find a way to point out the object of the group. Eg: 'admin' => { :attribute => 'role.name', :object => #<Role:0xb497494c> }
      group_by = group_by.map do |x|
        { :value      => x,
          :attribute  => @query.group.at(group_by.index(x)) }
      end
      
      group_row = query_group_tr(group_by, columns)
      rows      = group.last.map{ |record| generate_table_row(record, columns) }.join
      query_tbody("#{ group_row }#{ rows }")
    end
  end
  
  # Method to generate a row with a record and columns
  ## Take in account actions columns
  #
  def generate_table_row(record, columns)
    @query_object = record
    content = columns.map{ |column| query_td(column) }.join
    query_tr(content)
  end
  
  #################################################################
  ########################### criteria ############################
  
  def generate_attribute_chooser
    drop_down_menu_content ||= @organized_filters.map{ |n| generate_menu(n) }  ## cache that part to avoid resource wasting for each new criteria
    drop_down_menu = content_tag(:div, display_menu_link, :class => 'attribute') +
                     content_tag(:ul, drop_down_menu_content, :style => 'display:none;', :class => 'attribute_chooser')
    content_tag(:tr, :class => 'criterion new_criterion') do
      [content_tag(:td, drop_down_menu),
       content_tag(:td, tag(:span, :class =>'inputs'))]
    end
  end
  
  def menu_li(content, options = {})
    content_tag(:li, content, options.merge(:onmouseover => "showSubMenu(this);"))
  end
  
  def generate_menu(elements, selected = nil)
    unless elements.is_a?(Array)
      menu_li(apply_attribute_link(elements), :class => "#{ 'selected' if get_attribute(elements) == selected }") unless elements.is_a?(String) && elements.match(/id$/)
    else
      group    = elements.first
      paths    = elements.last
      active   = paths.select{ |n| n.is_a?(String) && n.match(/.id$/) }.any?
      sub_menu = paths.map{ |sub_paths| generate_menu(sub_paths, selected) }.join
      menu_li("#{ content_tag(:ul, sub_menu, :style => 'display:none') if sub_menu.any? }#{ apply_group_link(group, active) }", :class => ("sub_menu" if sub_menu.any?))
    end
  end
  
  def apply_attribute_link(path)
    attribute_alias = get_alias(path)
    attribute  = get_attribute(path)
    
    link_to_choose_attribute(attribute_alias, attribute)
  end
  
  def apply_group_link(path, active)
    group = path.split('.').last
    active ? link_to_choose_attribute(path, "#{ path }.id") : content_tag(:a, humanize_as_filter(path), :class => 'not_active') 
  end
  
  def link_to_choose_attribute(attribute_alias, attribute)
    link_to_function("#{ humanize_as_filter(attribute_alias) }") do |page|
      page << h("insertAttributeChooser(this)")
      page << h("replaceAttribute(this, '#{ escape_javascript(display_menu_link_for(attribute_alias)) }')")
      page << h("footPrint(this)")
      page << h("insertInputs(this, '#{ escape_javascript(generate_inputs_for(attribute)) }')")
    end
  end
  
  def display_menu_link
    content_tag(:span, I18n.t('link.add_criterion.name'), :class => 'new_criterion', :onclick => "showAttributeChooser(this)")
  end
  
  def display_menu_link_for(attribute)
    return nil unless attribute
    content = []
    parts   = attribute.split('.')
    parts.each_index do |i|
      content << content_tag(:span, humanize_as_filter(parts[0..i].join('.')), :class => ( i==(parts.size - 1) ? 'attribute' : 'relationship' ))
    end
    content_tag(:div, content.join, :onclick => "showAttributeChooser(this)")
  end
  
  def action_input(data_type, default, attribute)
    actions = if attribute.match(/.id$/)
      ['=','!='].map {|n| [HasSearchIndex::ACTIONS_TEXT[n], n]}
    else
      HasSearchIndex::ACTIONS[data_type.to_sym].map {|n| [HasSearchIndex::ACTIONS_TEXT[n], n]}
    end
    select_tag("criteria[#{ attribute }][action][]", options_for_select(actions, default))
  end
  
  def value_input(data_type, value, attribute)
    html_id = "criteria[#{ attribute }][value][]"
    case data_type
      when "string", "binary", "text"
        then text_field_tag(html_id, value)                                             
      when "boolean"
        then select_tag(html_id, options_for_select(['true', 'false'], value))
      when "integer", "decimal", "float"
        then text_field_tag(html_id, value, :onkeyup => 'isNumber(this);')
      when "datetime"
        then text_field_tag(html_id, value) + strong(" AAAA-MM-JJ hh:mm:ss")
      when "date"
        then text_field_tag(html_id, value) + strong(" AAAA-MM-JJ")
    end
  end
  
  # Method to generate inputs to give to user an object list where to pick up one or many as criterion value
  #
  def oject_input(value, attribute)
    model        = @page_configuration[:model].constantize
    relationship = attribute.split('.').at(-2)
    if attribute.chomp('.id').include?('.')
      attribute.chomp(".#{ relationship }.id").split('.').each do |part|
        model = model.reflect_on_association(part.to_sym).class_name.constantize
      end
    end
    
    reflection = model.reflect_on_association(relationship.to_sym)
    model      = reflection.class_name.constantize
    identifier = model.search_index[:identifier] || :to_s
    options    = {
      :conditions => reflection.options[:conditions], 
      :include    => reflection.options[:include], 
      :order      => reflection.options[:order],
      :group      => reflection.options[:group],
      :limit      => reflection.options[:limit]
    }
    
    collection = model.all(options).map {|n| [n.send(identifier), "#{ n.id }"]}
    multiple   = value && value.split(' ').many?
    input      = select_tag(nil, options_for_select(collection.sort, value ? value.split(' ') : value),
                        :multiple => multiple,
                        :onchange => 'applySelection(this, this.next("INPUT"))')
    input     += hidden_field_tag("criteria[#{ attribute }][value][]", value)
    input     += link_to_function(nil, 'toggleMultiple(this)', :class => "toggle_multiple_link #{ 'multiple' if multiple }")
  end
  
  def delete_link
    title = I18n.t('link.delete_criterion.title')
    link_to_function(image_tag('delete_16x16.png', :alt => title, :title => title), "this.up('.criterion').remove()", :class => 'delete_link')
  end
  
  def generate_inputs_for(attribute, options = {})
    attribute_type = data_type(attribute)
    if options.is_a?(Hash)
      value  = options[:value]
      action = options[:action]
    else
      value  = options
      action = attribute_type == 'string' ? 'like' : '='
    end
    
    inputs  = action_input(attribute_type, action, attribute)
    inputs += unless attribute.match(/.id$/)
      value_input(attribute_type, value, attribute)
    else
      oject_input(value, attribute)
    end
    
    return "#{ inputs }#{ delete_link }"
  end
  
  ###############################################################
  ###################### Private methods ########################
  
  private
    def should_render_quick_search?
      @can_quick_search && !(@page_name =~ /^advanced/)
    end
    
    # Methods to get attribute translation respecting a translate sources priority
    # +absolute+ means it use the page subject_model and the attribute full path
    # +relative+ means it use the model determined from the attribute full path like:
    #            -> attribute = last attribute part
    #            -> model     = model corresponding to last relationship
    # 
    # ==== example
    # subject_model = Employee
    # attribute_with_path = 'numbers.number_type.name'
    #
    # # absolute:
    # attribute = 'numbers.number_type.name'
    # model     = Employee
    #
    # # relative:
    # attirbute = 'name'
    # model     = NumberType
    #
    # You can add a level to add the ability to use absolute path and relationship at the same time
    # === example
    # You want to add an +absolute+ translation for 'civility.name' but you want to add a translation for 'civility' to.
    # With the current priority sources it is impossible because both the +absolute+ and relationship translations will be at the same place
    # So you can add a key in the Yaml at the same level of attributes and name it as 'relationships' to give a dedicated place to define relationships transaltions
    # Then add a line like lvl1 but replacing 'attributes' by 'relationships'.
    #
    def translate_with_priority(attribute_with_path, attribute, model)
      relative = "#{ model.to_s.tableize.singularize }.#{ attribute }"
      absolute = "#{ @query.subject_model.tableize.singularize }.#{ attribute_with_path }"
      
      lvl3 = attribute_with_path.split('.').last(2).join(' ').humanize
      lvl2 = I18n.t("activerecord.attributes.#{ relative }",         :default => lvl3)
      lvl1 = I18n.t("integrated_search.attributes.#{ relative }",    :default => lvl2)
      return I18n.t("integrated_search.attributes.#{ absolute }",    :default => lvl1)
    end
    
    def translate_filters_with_priority(attribute_with_path, attribute, model)
      absolute = "#{ @query.subject_model.tableize.singularize }.#{ attribute_with_path }"
      relative = "#{ model.to_s.tableize.singularize }.#{ attribute }"
      
      lvl2 = translate_with_priority(attribute_with_path, attribute, model)
      lvl1 = I18n.t("integrated_search.filters.#{ relative }", :default => lvl2)
      return I18n.t("integrated_search.filters.#{ absolute }", :default => lvl1)
    end
    
    # get a translation from a relative path
    # where the first relationshi will be used as model 
    #
    def translate_from(attribute_with_path, for_filters = false)
      model = @query.subject_model.constantize
      
      if attribute_with_path.include?('.') && attribute_with_path.split('.').last != 'id'
        parts        = attribute_with_path.split('.')
        relationship = parts.at(-2)
        attribute    = parts.last
        model        = model.search_index_relationship_class_name(attribute_with_path, relationship).constantize
      else
        attribute    = attribute_with_path
      end
      
      if for_filters
        translate_filters_with_priority(attribute_with_path, attribute, model)
      else
        translate_with_priority(attribute_with_path, attribute, model)
      end
    end
    
    # Method to make an attribute human readable using i18n and humanize method
    # do not use html undividable space "&nbsp;"
    #
    def humanize(attribute)
      translate_from(attribute)
    end
      
    # Method to make an attribute human readable using i18n and humanize method
    #
    def humanize_as_filter(attribute)
      translation = translate_from(attribute, for_filters = true)
      raise Exception, "#humanize_as_filter expected a String, but has a <#{translation.class.name}> when trying to translate <'#{attribute}'> => #{translation.inspect}" unless translation.is_a?(String)
      translation.gsub(' ', '&nbsp;')
    end
    
    # Method to get header content with or without sort feature
    # according to +column+ & +order+
    #
    def header_with_or_without_sort(column, order)
      content = humanize(column)
      if with_sort?(column, order)
        link_to_remote("#{ content } #{ get_direction_img(column, order)}",
          :update => 'integrated_search',
          :method => :get,
          :url => params.merge(:order_column => reverse_direction_for(column, order))
        )
      else
        content
      end
    end
    
    # Methods to reverse order 
    #
    def get_direction_img(column, order)
      main      = order.at(0) == column_with_direction(column, order) ? 'main_' : ''
      direction = HasSearchIndex.get_order_direction(column_with_direction(column, order))
      alt       = I18n.t("link.reverse_order.#{direction}")
      image_tag("search/#{ main }#{ direction }_arrow.png",  :alt => alt, :title => alt)
    end
    
    def column_with_direction(column, order)
      order.detect { |n| n =~ Regexp.new("^#{ column }:(desc|asc)$")}
    end
    
    def reverse_direction_for(column, order)
      column = column_with_direction(column, order)
      return column =~ /desc$/ ? column.gsub('desc','asc') : column.gsub('asc','desc')
    end
    
    def with_sort?(column, order)
      order.map{ |n| HasSearchIndex.get_order_attribute(n) }.include?(column)
    end
      
    def records_with_or_without_paginate(query, page)
      if with_paginate?(query)
        query.search.paginate(:page => page, :per_page => query.per_page)
      else
        query.search
      end
    end
    
    def with_paginate?(query)
      query.per_page && Query.respond_to?(:paginate)
    end
    
    def grouped_records(records, group_list)
      records.group_by {|record| group_list.map {|column| get_nested(record, column)} }
    end
    
    # get nested object, from an object and following an attribute path
    #
    # ==== example
    #
    # object = Employee.first
    # attribute = numbers.number_type.name
    # get_nestet(object, attirbute)
    # ##=> nil
    #
    # object = Employee.first
    # attribute = user.username
    # get_nestet(object, attirbute)
    # ##=> Employee.first.user.username
    #
    def get_nested(object, attribute)
      attribute.split('.').each do |element|
        object = (object.respond_to?(element) && !object.is_a?(Array) ? object.send(element) : nil)
      end
      object
    end
    
    # Method to get attribute type
    # 
    def data_type(attribute)
      @data_types[@page_name][attribute]
    end
    
    # Method to get filter alias from an attribute if it exist, return the attribute if not
    #
    def get_alias(attribute)
      filter = if attribute.is_a?(Hash)
        attribute
      else 
        HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym][:filters].detect {|n| n.is_a?(Hash) && n.values.first == attribute}
      end
      filter ? filter.keys.first : attribute
    end
    
    def get_attribute(arg)
      arg.is_a?(Hash) ? arg.values.first : arg
    end
    
    ##########################################################################################
    ##########################################################################################
    # 
    #  Methods below can be overrided in helpers, defining method with name matching pattern as described:
    #
    ## => query_MARKUP[_content][_for_COLUMN]_in_[PAGE_NAME|MODEL]
    #
    #
    # -> MARKUP        = [table, thead, tbody, thead_tr, tr, group_tr, th, td, group_td]
    # -> COLUMN        = attribute with dash to replace dot.
    # -> PAGE_NAME     = Query's +page_name+
    # -> MODEL         = Query's +subject_model+
    # -> [_content]    = used only for [td, th, group_td], permit to override those tag's content
    # -> [_for_COLUMN] = mandatory for [td, th, group_td], permit to identify a column
    #
    
    def query_table(content)
      helper = "query_table"
      override_for(helper) ? send(override_for(helper), content) : content_tag(:table, content)
    end
    
    def query_thead(content)
      helper = "query_thead"
      thead_content = query_thead_tr(content)
      override_for(helper) ? send(override_for(helper), thead_content) : content_tag(:thead, thead_content)
    end
    
    def query_thead_tr(content)
      helper = "query_thead_tr"
      override_for(helper) ? send(override_for(helper), content) : content_tag(:tr, content)
    end
    
    def query_th(column, order)
      helper  = "query_th_for_#{ column.gsub('.','_') }"
      content = query_th_content(column, order)
      override_for(helper) ? send(override_for(helper), content) : content_tag(:th, content)
    end
    
    def query_th_content(column, order)
      helper = "query_th_content_for_#{ column.gsub('.','_') }"
      override_for(helper) ? send(override_for(helper), column, order) : header_with_or_without_sort(column, order)
    end
    
    def query_tbody(content)
      helper = "query_tbody"
      override_for(helper) ? send(override_for(helper), content) : content_tag(:tbody, content)
    end
    
    def query_tr(content)
      helper = "query_tr"
      override_for(helper) ? send(override_for(helper), content) : content_tag(:tr, content)
    end
    
    def query_td(attribute)
      underscored_attribute = attribute.gsub('.','_')
      helper = "query_td_for_#{underscored_attribute}"
      content = query_td_content(attribute)
      override_for(helper) ? send(override_for(helper), content) : content_tag(:td, content, 'data-attribute' => underscored_attribute)
    end
    
    def query_td_content(attribute)
      helper = "query_td_content_for_#{ attribute.gsub('.','_') }"
      data   = override_for(helper) ? send(override_for(helper)) : get_nested(@query_object, attribute)
      type   = @query_object.class.search_index_attribute_type(attribute)
      return '-' if data.nil? && type != 'boolean'
      
      case type
        when "string", "text", "binary", "integer", "decimal", "float"
          data.to_s
        when "date", "datetime"
          data.humanize
        when "boolean"
          [1, true].include?(data) ? I18n.t("view.content.boolean_true") : I18n.t("view.content.boolean_false")
        else
          data
      end
    end
    
    def query_group_tr(group_by, columns)
      helper = "query_group_tr"
      content = query_group_td(group_by, columns)
      override_for(helper) ? send(override_for(helper), content) : content_tag(:tr, content, :class => 'group')
    end
    
    def query_group_td(group_by, columns)
      helper = "query_group_td"
      content = query_group_td_content(group_by)
      override_for(helper) ? send(override_for(helper), content) : content_tag(:td, content, :colspan => columns.size, :class => 'group')
    end
    
    def query_group_td_content(group_by)
      helper = "query_group_td_content"
      if override_for(helper)
        send(override_for(helper), group_by)
      else
        content = group_by.map!{ |n| n[:value].blank? ? I18n.t('view.content.undefined_group_name') : n[:value] }.join(' → ')
        content_tag(:span, content, :onclick => "toggleGroup(this);", :class => 'not-collapsed')
      end
    end
  
    def override_for(pattern)
      model_override = "#{ pattern }#{ @helper_end_with_model }"
      page_override  = "#{ pattern }#{ @helper_end_with_page_name }"
      
      if respond_to?(page_override)
        return page_override
      elsif respond_to?(model_override)
        return model_override
      else
        return nil
      end
    end
    ##########################################################################################
    ##########################################################################################
end

if Object.const_defined?("ActionView")
  ActionView::Helpers.send(:include, IntegratedSearchHelper)
end
