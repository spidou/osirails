module SearchesHelper

  def display_criterion_choose_select(value,id)
    model = Feature.find_by_name(value)
    html="<select onchange='action_choose(this,#{id})'><option id='blank#{id}' selected='selected'></option>"
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
  
  
        #categories.each_value do |attributes|
      #  html += get_attributes_recursively(attributes,model)
      #end
end
