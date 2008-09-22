module SearchesHelper

  def display_criterion_choose_select(value,id)
    model = Feature.find_by_name(value)
    
    month_array="["
    Date::MONTHNAMES.each do |month|
      month.nil? ? month = "" : month
      month_array +="\"" +  month  + "\"," 
    end
    month_array+="]"
    
    html="<select onchange='action_choose(this,#{id},#{month_array})'><option id='blank#{id}' selected='selected'></option>"
    model.search.each_pair do |model,categories|
      attributes = Search.regroup_attributes(categories)
      html += get_attributes_recursively(attributes,model) if model.constantize.can_view?(current_user)
    end
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
  
  
  def generate_rows(rows,columns)
    html = ""
    rows.each do |row|
      columns.each do |column|
        if column.class!={}.class
          html+="<td><tr>#{row.send(column)} </tr><td>\n"
        else
          html+="<td><tr>" + nested_column (row,column) + "</tr><td>\n"
        end  
      end 
    end 
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
      html<< generate_columns_contents(column.values[0]) 
    else
      html<< column.values[0]
    end
    return html
  end
  
end
