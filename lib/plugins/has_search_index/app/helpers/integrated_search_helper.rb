module IntegratedSearchHelper

  def apply_query_link
    link_to_remote("Appliquer",
                   { :url => url_for,
                     :method => :get,
                     :before => "valid_select_options('group columns');",
                     :update => @class_for_ajax_update,
                     :with => "Form.serialize('query_form')"
                   },
                     :title => 'Appliquer la nouvelle configuration')
  end
  
  def reset_query_link
    link_to("Restaurer", {:p => @page_name}, :title => 'Restaurer la configuration par défaut')
  end
  
  def new_query_link(text = "Sauvegarder")
    link_to("Créer", {}, :title => 'Sauvegarder en tant que nouvelle requête',
                         :onclick => "submit_form_for('new'); return false;")
  end
  
  def edit_query_link(query)
    link_to("Modifier", {}, :title => 'Sauvegarder en modifiant la requête',
                            :onclick => "submit_form_for('#{ query.id }/edit'); return false;")
  end
  
  def delete_query_link(query)
    link_to("Supprimer", query_path(query, :return_uri => url_for),
            :title => 'Supprimer la requête définitivement',
            :method => :delete,
            :confirm => 'Êtes vous sûr?')
  end
  
  def toggle_form_link(visible=true)
    content = content_tag(:span, content_tag(:span, 'Configuration'),
                                 :onclick => "toggle_integrated_form('#{ @page_name }', this)",
                                 :class   => "toggle_#{ visible ? 'hide' : 'show' }",
                                 :title   => 'Personnaliser le rapport')
    content_tag(:div, content, :class => 'toggle_link')
  end
  
  def links(query)
    links  = [apply_query_link, reset_query_link, new_query_link]
    links += [edit_query_link(query), delete_query_link(query)] if (!query.new_record? && query.creator == current_user)
    content_tag(:div, links.join, :class => "public_links")
  end
  
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
  
  def title_for_search
    (@query.name||@page_name).titleize #t(@page_name.to_sym)
  end
  
  
  
  ##########################################################################################
  ################################# Methods to generate table ##############################
  ##########################################################################################
  
  def table_for_search
    usable_queries = Query.all(:conditions => ["page_name = ? and name != ? and (creator_id = ? or public_access = ?)", @page_name, @query.name||'', current_user, true])
    usable_queries.each do |saved_query|
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
    @helper_end = "_in_#{ query.page_name }"
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
  
  ##############
  ## criteria
  
  def generate_attribute_chooser
    drop_down_menu_content ||= @organized_filters.map {|n| generate_menu(n)}  ## cache that part to avoid resource wasting for each new criteria
    drop_down_menu = content_tag(:div, display_menu_link, :class => 'attribute') +
                     content_tag(:ul, drop_down_menu_content, :style => 'display:none;', :class => 'attribute_chooser')
    content_tag(:tr, :class => 'criterion') do
      [content_tag(:td, drop_down_menu),
       content_tag(:td, tag(:span, :class =>'inputs'))]
    end
  end
  
  # # TODO manage here Globalization I18n
  #
  def generate_menu(elements, selected = nil)
    group = elements.first
    paths = elements.last
    if group.nil?
      paths.map {|path| menu_li(apply_attribute_link(path), :class => "#{ 'selected' if path == selected }") }.join
    else
      content = paths.map {|sub_paths| generate_menu(sub_paths, selected)}.join
      menu_li("#{ content_tag(:ul, content, :style => 'display:none') }#{ content_tag(:a, humanize(group)) }", :class => "sub_menu")
    end  
  end
  
  def menu_li(content, options = {})
    content_tag(:li, content, options.merge(:onmouseover => "showSubMenu(this);"))
  end
  
  # # TODO manage here Globalization I18n
  #
  def apply_attribute_link(arg)
    link_name  = arg.is_a?(Hash) ? arg.keys.first   : arg.split('.').last
    attribute  = arg.is_a?(Hash) ? arg.values.first : arg
    label_name = arg.is_a?(Hash) ? link_name        : attribute
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
    text.split('.').reverse.each_with_index do |part, i| #text.split(':').first
      content.unshift(content_tag(:span, humanize(part), :class => ( i==0 ? 'attribute' : 'relationship' )))
    end
    content_tag(:div, content.join, :onclick => "showAttributeChooser(this)")
  end
  
  # # TODO manage here Globalization I18n
  #
  def generate_inputs_for(attribute, options = {})
    index   = rand(1000000).to_s
    html_id = "criteria[#{ index }][value]"
    input   = case data_type(attribute)
      when "string", "binary", "text" then
        text_field_tag(html_id, options[:value])                                             
      when "boolean" then
        select_tag(html_id, options_for_select(['true', 'false'], options[:value]))
      when "integer", "decimal", "float" then
        text_field_tag(html_id, options[:value], :onkeyup => 'isNumber(this);')
      when "datetime" then
        text_field_tag(html_id, options[:value]) + strong(" AAAA-MM-JJ hh:mm:ss")
      when "date" then
        text_field_tag(html_id, options[:value]) + strong(" AAAA-MM-JJ")
    end
    return "#{ action_select(data_type(attribute), index, options[:action]) }#{ input }#{ attribute_hidden_field(attribute, index) }#{ delete_link }"   
  end
  
  def action_select(data_type, index, default)
    actions = HasSearchIndex::ACTIONS[data_type.to_sym].map {|n| [HasSearchIndex::ACTIONS_TEXT[n], n]}
    select_tag("criteria[#{ index }][action]", options_for_select(actions, default))
  end
  
  def attribute_hidden_field(value, index)
    hidden_field_tag("criteria[#{ index }][attribute]", value)
  end
  
  # # TODO manage here Globalization I18n
  #
  def delete_link
    link_to_function(image_tag('delete_16x16.png', :alt => 'delete', :title => 'delete'), "this.up('.criterion').remove()", :class => 'delete_link')
  end
  
  def data_type(attribute)
    @data_types[@page_name][attribute]
  end
  
  # # TODO manage here Globalization I18n
  #
  def get_alias(attribute)
    filter = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym][:filters].detect {|n| n.is_a?(Hash) && n.values.first == attribute}
    filter ? filter.keys.first : attribute
  end
  
  # # TODO manage here Globalization I18n
  #
  def humanize(attribute)
    attribute.humanize.gsub(' ', '&nbsp;')
  end
  
  ############## Private methods #################
  private
  
    # Method to get header content with or without sort feature
    # according to +column+ & +order+
    # # TODO manage here Globalization I18n
    #
    def header_with_or_without_sort(column, order)
      content = column.split('.').last(2).join(' ').humanize
      if with_sort?(column, order)
        link_to_remote("#{ content } #{ get_direction_img(column, order)}",#{ way_img if order.at(0) == column_with_direction(column, order)}",
          :update => 'integrated_search',
          :method => :get,
          :url => params.merge(:order_column => reverse_direction_for(column, order))
        )
      else
        content
      end
    end
    
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
    
  
  ##########################################################################################
  ##########################################################################################
  # 
  #  Methods below can be overrided in helpers, definning method with name matching pattern as described:
  #
  ## => query_MARKUP_[content_]for_MODEL[_COLUMN]
  #
  #
  # -> MARKUP     = [table, thead, tbody, thead_tr, tr, group_tr, th, td, group_td]
  # -> COLUMN     = attribute with dash to replace dot.
  # -> MODEL      = model that will be search subject
  # -> [content_] = used only for [td, th, group_td], permit to override those tag's content
  # -> [_COLUMN]  = mandatory for [td, th, group_td], permit to identify a column
  #
    
    def query_table(content)
      helper = "query_table#{ @helper_end }"
      respond_to?(helper) ? send(helper, content) : content_tag(:table, content)
    end
    
    def query_thead(content)
      helper = "query_thead#{ @helper_end }"
      thead_content = query_thead_tr(content)
      respond_to?(helper) ? send(helper, thead_content) : content_tag(:thead, thead_content)
    end
    
    def query_thead_tr(content)
      helper = "query_thead_tr#{ @helper_end }"
      respond_to?(helper) ? send(helper, content) : content_tag(:tr, content)
    end
    
    def query_th(column, order)
      helper  = "query_th_for_#{ column.gsub('.','_') }#{ @helper_end }"
      content = query_th_content(column, order)
      respond_to?(helper) ? send(helper, content) : content_tag(:th, content)
    end

    # TODO manage here Globalization I18n
    def query_th_content(column, order)
      helper = "query_th_content_for_#{ column.gsub('.','_') }#{ @helper_end }"
      respond_to?(helper) ? send(helper, column, order) : header_with_or_without_sort(column, order)
    end
    
    def query_tbody(content)
      helper = "query_tbody#{ @helper_end }"
      respond_to?(helper) ? send(helper, content) : content_tag(:tbody, content)
    end
    
    def query_tr(content)
      helper = "query_tr#{ @helper_end }"
      respond_to?(helper) ? send(helper, content) : content_tag(:tr, content)
    end
    
    def query_td(attribute)
      helper = "query_td_for_#{ attribute.gsub('.','_') }#{ @helper_end }"
      content = query_td_content(attribute)
      respond_to?(helper) ? send(helper, content) : content_tag(:td, content)
    end
    
    # TODO manage here Globalization I18n
    def query_td_content(attribute)
      helper = "query_td_content_for_#{ attribute.gsub('.','_') }#{ @helper_end }"
      data   = respond_to?(helper) ? send(helper) : get_nested(@query_object, attribute)
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
      helper = "query_group_tr#{ @helper_end }"
      content = query_group_td(group_by, columns)
      respond_to?(helper) ? send(helper, content) : content_tag(:tr, content, :class => 'group')
    end
    
    def query_group_td(group_by, columns)
      helper = "query_group_td#{ @helper_end }"
      content = query_group_td_content(group_by)
      respond_to?(helper) ? send(helper, content) : content_tag(:td, content, :colspan => columns.size )
    end
    
    # TODO manage here Globalization I18n
    # FIXME keep actual nil values management ?
    #
    def query_group_td_content(group_by)
      helper = "query_group_td_content#{ @helper_end }"
      content = group_by.map! {|n| n.blank? ? 'Non définis' : n }.join(' → ')
      respond_to?(helper) ? send(helper, group_by) : content_tag(:span, content, :onclick => "toggle_group(this);", :class => 'group_subject')
    end
  
  ##########################################################################################
  ##########################################################################################
end
