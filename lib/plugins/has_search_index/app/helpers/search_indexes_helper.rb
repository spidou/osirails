module SearchIndexesHelper

  def generate_table_headers(columns, nested_columns=[])
    html = "<table>"
    html << "<tr>"
    
    # direct attributes
    columns.each do |column|
      rowspan = "" #nested_columns.empty? ? "" : "rowspan='2'"
      html << "<th #{rowspan} >#{column.humanize.titleize}</th>"
    end
    # FIXME that part is commented because it don't work properly for some deep nested ressources
    # nested attributes models
#    nested_columns.keys.sort.each do |prefix|
#      html += "<th colspan='#{nested_columns[prefix].size}' >#{prefix.gsub("."," > ")}</th>"
#    end
#    html+= "</tr><tr>"
#    # nested attributes
#    nested_columns.keys.sort.each do |prefix|
#      nested_columns[prefix].each do |value|
#        html += "<th>;#{value.humanize}</th>"
#      end
#    end
    
    html << "<th>Actions</th>"
    html << "</tr>"
  end
  
  # FIXME that part is unused because there is a problem of conception when deals with deep nested resources 
  def generate_nested_resources_array(criteria)
    criteria_hash = {}
    criteria.each do |criterion|
      if criterion['attribute'].include?(".")
        attribute = criterion['attribute'].split(".").last
        attribute_prefix = criterion['attribute'].chomp(".#{attribute}")
        if criteria_hash.keys.include?(attribute_prefix)
          criteria_hash[attribute_prefix] << attribute  unless criteria_hash[attribute_prefix].include?(attribute)
        else
          criteria_hash = criteria_hash.merge({ attribute_prefix => [ attribute ] })
        end
      end
    end
    return criteria_hash
  end
  
  def generate_results_table_cells(collection, columns, nested_columns=[])
    html = ""
    collection.each do |object|
      html += "<tr>"
      # direct attributes
      columns.each do |attribute|
        data = format_date(object.send(attribute)) if object.respond_to?(attribute)
        html += "<td>#{data||=""}</td>" 
      end
      # FIXME that part is commented because it don't work properly for some deep nested ressources
#      # nested attributes 
#      nested_columns.keys.sort.each do |key|
#        if object.respond_to?(key)
#          nested_columns[key].each do |attribute|
#            if object.send(key).respond_to?(attribute)
#              data = (object.send(key).send(attribute).nil? )? "null" : "#{ format_date(object.send(key).send(attribute)) }"
#              html+="<td>#{data}</td>"
#            elsif object.send(key).is_a?(Array)
#              data = "null" if object.send(key).empty? 
#              html+= "<td>#{data}"
#              object.send(key).each do |elm| 
#                html+= "#{format_date(elm.send(attribute))}<br/>" if elm.respond_to?(attribute)
#              end
#              html+= "</td>"
#            else
#              html+= "<td>unknown data #{attribute}</td>"
#            end
#          end
#        end
#      end

      html += "<td>#{send("#{object.class.to_s.downcase}_link", object, :link_text => '')}</td>" if respond_to?("#{object.class.to_s.downcase}_path")
      html += "</tr>"
    end
    return html
  end
  
  def format_date(result)
    if result.class == ActiveSupport::TimeWithZone
      return result.strftime("%d %b %Y at %H:%M")
    elsif result.class == Date
      return result.strftime("%d %b %Y")
    elsif result.class == DateTime
      return result.strftime("%d %b %Y at %H:%M")
    elsif result.class == Time
      return result.strftime("%H:%M")
    else
      return result
    end
  end
  
  # method to generate an hash containing the direct attributes of a model
  def generate_attributes_hash(model)
    model.search_index[:attributes].merge(model.search_index[:additional_attributes])
  end
  
  # method to generate a hash that contain all relationships and their own relationships
  # for a model according according to that model's include_array
  #
  def generate_relationships_hash(include_array,parent_model,ancestor=nil,relationship="")
    result = {}
    ancestor ||= parent_model
    include_array.each do |element|      
      if element.is_a?(Hash)
        element.each do |key, value|
          model = parent_model.constantize.association_list[key][:class_name]        
          (result["#{ancestor}#{relationship}"]||=[]) << ["#{parent_model}.#{key.to_s}", model]       
          result = result.merge(generate_relationships_hash(value, model, parent_model, ".#{key.to_s}"))
        end
      else
        model = parent_model.constantize.association_list[element][:class_name]
        (result["#{ancestor}#{relationship}"]||=[]) << ["#{parent_model}.#{element.to_s}", model]
      end
    end
    return result
  end
  
end
