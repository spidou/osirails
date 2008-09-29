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
    if model.constantize.respond_to?('can_view?')
      html += get_attributes_recursively(attributes,model) if model.constantize.can_view?(current_user)
    else
      html += get_attributes_recursively(attributes,model)
    end
    
    html+="</select name=\"criteria[#{id}][attribute]\" >"
    return html    
  end
  
  # methods to get the attribute recursively and to display it 
  # into otions that are under optgoups to respect a hierarchy
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
  
  # method to generate result array's rows 
  def generate_rows(objects,columns)
    html = ""
    objects.each do |object|
      html+="<tr>"
      columns.each do |column|
        result = object
        column.each do |attribute|
          # if the attribute return an array the tab will show a link (that will display an alert prompt to see the collection )
          if result.class == Array
          
            ### generate the tab to pass 
            # as arg into collection_display method
            tab = "['"
            puts result.inspect + "|" + attribute
            result.each do |element|
              tab == "['" ? sep = "" : sep = "','"
              tab << sep + element.send(attribute).to_s 
            end
            tab += "']" 
            ############################
            
            html += "<td onclick=\"return collection_display(#{tab},'#{attribute}');\"> <a >voir</a></td>"
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
  

  
end
