module IntegratedSearchHelper

  # TODO manage here Globalization I18n
  #
  def apply_query_link
    link_to_remote("Appliquer",
                   { :url => url_for,
                     :method => :get,
                     :before => "validSelectOptions('group columns');",
                     :update => @class_for_ajax_update,
                     :with => "Form.serialize('query_form')"
                   },
                     :title => 'Appliquer la nouvelle configuration',
                     :class => 'apply')
  end
  
  # TODO manage here Globalization I18n
  #
  def reset_query_link
    link_to("Restaurer", {:p => @page_name}, :title => 'Restaurer la configuration par défaut')
  end
  
  # TODO manage here Globalization I18n
  #
  def new_query_link(text = "Sauvegarder")
    link_to("Créer", {}, :title => 'Sauvegarder en tant que nouvelle requête',
                         :onclick => "submitFormFor('new'); return false;")
  end
  
  # TODO manage here Globalization I18n
  #
  def edit_query_link(query)
    link_to("Modifier", {}, :title => 'Sauvegarder en modifiant la requête',
                            :onclick => "submitFormFor('#{ query.id }/edit'); return false;")
  end
  
  # TODO manage here Globalization I18n
  #
  def delete_query_link(query)
    link_to("Supprimer", query_path(query, :return_uri => url_for),
            :title => 'Supprimer la requête définitivement',
            :method => :delete,
            :confirm => 'Êtes vous sûr?')
  end
  
  # TODO manage here Globalization I18n
  #
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
      link_to_remote('Annuler X',
        remote_options,
        :title => 'Annuler les modifications effectuées',
        :class => 'reset_query_link',
        :style => "#{ 'display:none' unless @can_be_cancelled }"
      )
    end
  end
  
  # TODO manage here Globalization I18n
  #
  def toggle_form_link(visible = true)
    link = content_tag(
      :span, nil,
      :onclick => "toggleIntegratedForm('#{ @page_name }', this)",
      :class   => "toggle_integrated_form",
      :title   => 'Personnaliser le rapport'
    )
                       
    content_tag(:div, :class => 'toggle_link') do
      content_tag(:span, :class   => "quick_search") { [link, quick_search(!visible)] }
    end
  end
  
  # TODO manage here Globalization I18n
  #
  def quick_search(visible = true)
    return if @page_name =~ /^advanced/ || !@can_quick_search
    
    submit_function = remote_function({
      :url    => params.reject {|k,v| k.to_s == 'key_word'},
      :method => :get,
      :update => @class_for_ajax_update,
      :with   => "'key_word=' + this.up().down('INPUT').value"
    })
  
    content  = text_field_tag(nil, @query.quick_search_value, :onkeypress => "if(event.which == Event.KEY_RETURN){ #{ submit_function }; return false }")
    content += link_to_function(nil, submit_function, :title => 'Rechercher')
    
    content_tag(:span, content, :class => 'quick_search_inputs', :style => ("display:none;" unless visible))
  end
  
  # TODO manage here Globalization I18n
  #
  def links(query)
    links  = [apply_query_link, new_query_link]
    links += [edit_query_link(query), delete_query_link(query)] if (!query.new_record? && query.creator == current_user)
    content_tag(:div, links.join, :class => "public_links")
  end
  
  # TODO manage here Globalization I18n
  #
  def add_order_link(page_config)
    message = "Ajouter une attribut pour le tri"
    link_to_function(image_tag("add_16x16.png", :alt => message, :title => message)) do |page|
      partial = escape_javascript(render(:partial => "shared/order_option",
                                         :locals => {:page_config => page_config} ))
      page << h("this.parentNode.previous().insert({bottom: '#{ partial }'})")
    end
  end
  
  def paginate_per_page(query)
    per_pages = HasSearchIndex::HTML_PAGES_OPTIONS[query.page_name.to_sym][:per_page] + [ nil ]
    
    content_tag(:div, :class => 'pagination per_pages') do
      [content_tag(:span, 'Per page : ')] + per_pages.map do |per_page|
        query.per_page == per_page ? content_tag(:span, paginate_text(per_page), :class => 'current') : content_tag(:span, paginate_link(per_page))
      end
    end
  end

  
  # Method to prepare collection to be used with 'options_for_select'# TODO manage here Globalization I18n
  # 
  def prepare_for_options(collection)
    collection.map {|n| n && [n.split('.').last(2).join(' '), n] }
  end
  
  # Method to create a link permitting to modify pagination option with Ajax
  #
  def paginate_link(per_page)
    link_to_remote(paginate_text(per_page), :update => @class_for_ajax_update, :method => :get, :url => params.merge(:per_page => per_page || 'all'))
  end
  
  # TODO manage here Globalization I18n
  #
  def paginate_text(per_page)
    per_page ? per_page.to_s : 'all'
  end
  
  # TODO manage here Globalization I18n
  #
  def title_for_search
    (@query.name||@page_name).titleize #t(@page_name.to_sym)
  end
  
  #################################################################
  ################## Methods to generate table ####################
  
  # # TODO manage here Globalization I18
  # 
  def table_for_search
    saved_queries = Query.all(:conditions => ["page_name = ? and name != ? and (creator_id = ? or public_access = ?)",
                                              @page_name, @query.name||'', current_user.id, true])
    
    if @query.name && @query.name != @default_query_name 
      add_contextual_menu_item(:personalized_queries) do 
        link_to("#{ image_tag('view_16x16.png') } #{ @default_query_name }", :p => @page_name)
      end
    end
    
    saved_queries.each do |saved_query|
      add_contextual_menu_item(:personalized_queries) do
        link_to("#{ image_tag('view_16x16.png') } #{ saved_query.name }", :query_id => saved_query.id)
      end
    end
    
    render(@query_render_options)
  end
  
  # Method to generate table form query
  # # TODO manage here Globalization I18
  #
  def generate_table(query, page)
    @helper_end_with_page_name = "_in_#{ query.page_name }"
    @helper_end_with_model = "_in_#{ query.subject_model.downcase }"
    header  = generate_table_header(query)
    records = records_with_or_without_paginate(query, page)
    body    = generate_table_body(records, query.columns, query.group)
    table   = query_table("#{ header }#{ body }")
    pagination = generate_pagination(records, query)
    
    records.empty? ? content_tag(:div, "Aucun résultat correspondant à la recherche", :class => 'search_no_result') : "#{ table }#{ pagination }"
  end
  
  # Method to generate pagination links
  #
  def generate_pagination(records, query)
    options = {
      :renderer               => 'RemoteLinkRenderer',
      :method_for_remote_link => :get,
      :remote                 => { :update => @class_for_ajax_update }
    }
    "#{ will_paginate(records, options) if with_paginate?(query)} #{ paginate_per_page(query) }"
  end
  
  # Methods to generate header from columns
  ## Take in account actions columns
  #
  def generate_table_header(query)
    columns_with_action = query.columns + ['actions']                                                  # special handle actions column
    query_thead(columns_with_action.map {|column| query_th(column, query.order)}.join)
  end
  
  # Methods to generate a table body from a query
  #
  def generate_table_body(records, columns, group)
    content = if group && group.any?
      generate_grouped_table_rows(records, columns, group)
    else
      query_tbody(records.map {|record| generate_table_row(record, columns)}.join)
    end
  
    content
  end
  
  # Method to generate grouped rows with records
  # group_list is an Array of group wich will permit to group with nested levels
  ## Take in account actions columns
  #
  def generate_grouped_table_rows(records, columns, group_list)
    grouped_records(records, group_list).map do |group|
      group_row = query_group_tr(group.first, columns + ['actions'])                                  # special handle actions column
      rows      = group.last.map {|record| generate_table_row(record, columns)}.join
      query_tbody("#{ group_row }#{ rows }")
    end
  end
  
  # Method to generate a row with a record and columns
  ## Take in account actions columns
  #
  def generate_table_row(record, columns)
    @query_object = record
    columns_with_action = columns + ['actions']                                                        # special handle actions column
    content = columns_with_action.map {|column| query_td(column)}.join
    query_tr(content)
  end
  
  #################################################################
  ########################### criteria ############################
  
  def generate_attribute_chooser
    drop_down_menu_content ||= @organized_filters.map {|n| generate_menu(n)}  ## cache that part to avoid resource wasting for each new criteria
    drop_down_menu = content_tag(:div, display_menu_link, :class => 'attribute') +
                     content_tag(:ul, drop_down_menu_content, :style => 'display:none;', :class => 'attribute_chooser')
    content_tag(:tr, :class => 'criterion') do
      [content_tag(:td, drop_down_menu),
       content_tag(:td, tag(:span, :class =>'inputs'))]
    end
  end
  
  def menu_li(content, options = {})
    content_tag(:li, content, options.merge(:onmouseover => "showSubMenu(this);"))
  end
  
  # # TODO manage here Globalization I18n
  #
  def generate_menu(elements, selected = nil)
    unless elements.is_a?(Array)
      menu_li(apply_attribute_link(elements), :class => "#{ 'selected' if get_attribute(elements) == selected }") unless elements.is_a?(String) && elements.match(/id$/)
    else
      group    = elements.first
      paths    = elements.last
      active   = paths.select {|n| n.is_a?(String) && n.match(/.id$/)}.any?
      sub_menu = paths.map {|sub_paths| generate_menu(sub_paths, selected)}.join
      menu_li("#{ content_tag(:ul, sub_menu, :style => 'display:none') if sub_menu.any? }#{ apply_group_link(group, active) }", :class => ("sub_menu" if sub_menu.any?))
    end  
  end
  
  # # TODO manage here Globalization I18n
  #
  def apply_attribute_link(path)
    link_name  = path.is_a?(Hash) ? path.keys.first : path.split('.').last
    attribute  = get_attribute(path)
    label_name = path.is_a?(Hash) ? link_name      : attribute
    
    link_to_choose_attribute(link_name, label_name, attribute)
  end
  
  def apply_group_link(path, active)
    group = path.split('.').last
    active ? link_to_choose_attribute(group, path, "#{ path }.id") : content_tag(:a, humanize(group), :class => 'not_active') 
  end
  
  def link_to_choose_attribute(link_name, label_name, attribute)
    link_to_function("#{ humanize(link_name) }") do |page|
      page << h("insertAttributeChooser(this)")
      page << h("replaceAttribute(this, '#{ escape_javascript(display_menu_link_for(label_name)) }')")
      page << h("footPrint(this)")
      page << h("insertInputs(this, '#{ escape_javascript(generate_inputs_for(attribute)) }')")
    end
  end
  
  # # TODO manage here Globalization I18n
  #
  def display_menu_link
    content_tag(:span, 'Ajouter un critère', :class => 'new_criterion', :onclick => "showAttributeChooser(this)")
  end
  
  def display_menu_link_for(text)
    return nil unless text
    content = []
    text.split('.').reverse.each_with_index do |part, i|
      content.unshift(content_tag(:span, humanize(part), :class => ( i==0 ? 'attribute' : 'relationship' )))
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
    multiple   = value && value.split(' ').size > 1
    input      = select_tag(nil, options_for_select(collection.sort, value ? value.split(' ') : value),
                        :multiple => multiple,
                        :onchange => 'applySelection(this, this.next("INPUT"))')
    input     += hidden_field_tag("criteria[#{ attribute }][value][]", value)
    input     += link_to_function(nil, 'toggleMultiple(this)', :class => "toggle_multiple_link #{ 'multiple' if multiple }")
  end
  
  # # TODO manage here Globalization I18n
  #
  def delete_link
    link_to_function(image_tag('delete_16x16.png', :alt => 'delete', :title => 'delete'), "this.up('.criterion').remove()", :class => 'delete_link')
  end
  
  # # TODO manage here Globalization I18n
  #
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
  
    # Method to get header content with or without sort feature
    # according to +column+ & +order+
    # # TODO manage here Globalization I18n
    #
    def header_with_or_without_sort(column, order)
      content = column.split('.').last(2).join(' ').humanize
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
    
    # # TODO manage here Globalization I18n
    #
    def get_direction_img(column, order)
      main      = order.at(0) == column_with_direction(column, order) ? 'main_' : ''
      direction = HasSearchIndex.get_order_direction(column_with_direction(column, order))
      alt       = direction == 'desc' ? 'Ascendant' : 'Descendant'
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
      order.map {|n| HasSearchIndex.get_order_attribute(n) }.include?(column)
    end
      
    # Methods to get pagination support
    #
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
    # # TODO manage here Globalization I18nreset
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
    
    # Method to format properly the attribute
    # # TODO manage here Globalization I18n
    #
    def humanize(attribute)
      attribute.humanize.gsub(' ', '&nbsp;')
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

    # TODO manage here Globalization I18n
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
      helper = "query_td_for_#{ attribute.gsub('.','_') }"
      content = query_td_content(attribute)
      override_for(helper) ? send(override_for(helper), content) : content_tag(:td, content)
    end
    
    # TODO manage here Globalization I18n
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
          [1, true].include?(data) ? 'Oui' : 'Non' 
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
    
    # TODO manage here Globalization I18n
    #
    def query_group_td_content(group_by)
      helper = "query_group_td_content"
      content = group_by.map! {|n| n.blank? ? 'Non définis' : n }.join(' → ')
      override_for(helper) ? send(override_for(helper), group_by) : content_tag(:span, content, :onclick => "toggleGroup(this);", :class => 'not-collapsed')
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
