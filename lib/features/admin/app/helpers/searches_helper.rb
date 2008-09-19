module SearchesHelper

  def display_model_choose_select(value)
    model = Feature.find_by_name(value)
    html="<select onchange='action_choose(this)'>"
    model.search.each_pair do |model,categories|
      attributes = Search.regroup_attributes(categories)
      html += get_attributes_recursively(attributes,model)
    end
    html+="</select>"
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
        sub_html = get_attributes_recursively(type,attribute)
      else
        html+="<option value='#{attribute},#{type}'>#{attribute}</option> "
      end
    end
    html += opt + sub_html
    return html
  end
  
  
        #categories.each_value do |attributes|
      #  html += get_attributes_recursively(attributes,model)
      #end
end