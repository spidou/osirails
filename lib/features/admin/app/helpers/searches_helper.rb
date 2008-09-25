module SearchesHelper

  def display_criterion_choose_select(value,id)
    # take the first part of value that represent the feature name
    return "" if value.nil?
    feature = Feature.find_by_name(value.split(",")[0])
    model = value.split(",")[1]
    
    # OPTIMIZE use .inspect on the constant and replace nil by "" (Date::MONTHNAMES[0])
    month_array="["
    Date::MONTHNAMES.each do |month|
      month.nil? ? month = "" : month
      month_array +="\"" +  month  + "\"," 
    end
    month_array+="]"
    
    html="<select name='criteria[#{id}][attribute]' onchange='action_choose(this,#{id},#{month_array})'><option id='blank#{id}' selected='selected'></option>"
    #feature.search.each_pair do |model,categories|
    #  attributes = Search.regroup_attributes(categories)
    #  html += get_attributes_recursively(attributes,feature) if feature.constantize.can_view?(current_user)
    #end
    attributes = feature.search[model]['base'].fusion(feature.search[model]['other'])
    html += get_attributes_recursively(attributes,model) if model.constantize.can_view?(current_user)
    
    html+="</select name=\"criteria[#{id}][attribute]\" >"
    return html    
  end
  
  def get_attributes_recursively(attributes,parent)
    if attributes.size==1 and attributes.values[0].class=={}.class 
      html = ""
      opt = "" 
    else
      html = "<optgroup label='#{parent}' >"
      opt = "</optgroup>" 
    end
    sub_html = ""
    attributes.each_pair do |attribute,type|
      if type.class == {}.class
        if type.size==1 and type.values[0].class=={}.class 
          sub_html += get_attributes_recursively(type,attribute)
        elsif attribute.constantize.respond_to?('can_view?')
          sub_html += get_attributes_recursively(type,attribute) if attribute.constantize.can_view?(current_user)
        else
          sub_html += get_attributes_recursively(type,attribute)
        end  
      else
        html+="<option value='#{attribute},#{type}'>#{attribute}</option> "
      end
    end
    html += opt + sub_html
    return html
  end
  
  
  def generate_rows(objects,columns)
    html = ""
    objects.each do |object|
      html+="<tr>"
      puts columns.inspect
      columns.each do |column|
        result = object
        column.each do |attribute|
          if result.class == Array
            html += "<td>" + link_to("voir",object) + "</td>"
            result = ""
          else
            result = result.send(attribute) unless result.blank?
          end
        end
        result = "null" if result.nil?
        html+="<td>#{result}</td>\n" unless result.blank?
      end
      html+="</tr>" 
    end
    return html 
  end
  
  def nested_column(row,column)
    e = row.send(column.keys[0])
    generate_columns_contents(column.values[0]).each do |attribute|
      e = e.send(attribute)
    end
    return e
  end
  
  def generate_columns_contents(column)
    html=[column.keys[0]]
    if column.values[0].class
      html << generate_columns_contents(column.values[0]) 
    else
      html << column.values[0]
    end
    return html
  end
  
end
