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
    
    html="<select name='criteria[#{id}][attribute]' onchange='action_choose(this,#{id},#{month_array})'><option id='blank#{id}' selected='selected'>Veuillez choisir un crit&egrave;re</option>"
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
      html+="<tr><td >" + link_to("<img src='/images/view_16x16.png' alt='voir' title='Voir'/></td>",object)
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
        
        ## get all criteria in an array
        # criteria = []
        # params[:criteria].each_value do |c|
        #  c[:value].nil? ? criteria << "#{c['date(3i)']}/#{c['date(2i)']}/#{c['date(1i)']}" : criteria << c[:value]
        # end
        # html+="<td>#{highlight(result, criteria.sort_by{ |c| c.size }.reverse)}</td>\n" unless result.blank?
        
        result = Search.format_date(result)
        
        html+="<td>#{result}</td>" +"\n" unless result.blank?        
      end
      html+="</tr>" 
    end
    return html 
  end
  
  # method to display the array '<th>' with hierarchy
  def result_table_headers(columns)
    tab = []
    columns.each do |c|
      tab << c.values_at(-2).first if c.size>1
    end
    # attributes
    html = "<th style='width:10px;' > (↓) </th>"
    columns.each do |column| 
      if column.size==1
      html += "<th rowspan='2' >#{column.last.humanize}</th>"
      end
    end
    # sub attributes titles
    tab.uniq.each do |title|
      html += "<th colspan='#{tab.count(title)}'>#{title.humanize}</th>"
    end
    html+= "</tr><tr>"
    # sub attributes
    columns.each do |column|
      html += "<th>#{column.last.humanize}</th>" if column.size>1 
    end
    
    return html
  end
  
  def model_select(searches,choosen_model)
    html = "<select id=\"model_select\" name=\"model[name]\" onchange=\"has_criteria(this);\">"
    Search.include_model?(searches,choosen_model) ? selected = "" : selected = "selected=\"selected\""   
    
    html+="<option #{selected}>Veuillez choisir une section</option>"  
    searches.each_pair do |feature,models|
      html+="<optgroup label='#{ feature }'"
      models.each do |model|
        # model == choosen_model ? m_selected = "selected=\"selected\"" : m_selected = ""
        m_selected = ""
        html+="<option #{m_selected} value='#{ feature },#{ model }'> #{ model }</option>"
      end
    end
    html+="</select>"
  end
  # Small hack to catch the model name with the controller object
  def get_model_name(model_param)
     return model_param if model_param.count(">")==0
     return model_param.split("<")[1].split(":")[0].gsub(/Controller/,"").singularize unless model_param.nil?
  end
  
end
