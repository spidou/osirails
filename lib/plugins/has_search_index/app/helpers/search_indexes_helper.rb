module SearchIndexesHelper
  
  # Method to generate table_header for search result
  # direct_attribute = called from the object
  # nested_attributes = attributes that come from object's relationships hierarchy
  #
  def generate_table_headers(direct_attributes, nested_attributes=[])
    html = "<tr>"
    # direct attributes
    rowspan = (nested_attributes.empty?)? "" : "rowspan='2'"
    direct_attributes.each do |attribute|    
      html << "<th #{rowspan} >#{attribute.to_s.humanize.titleize}</th>"
    end
    if nested_attributes.empty?
      html += "<th>Actions</th></tr>"
    else
      # nested attributes models
      nested_attributes.keys.sort.each do |prefix|
        html += "<th colspan='#{nested_attributes[prefix].size}' >#{prefix.gsub("."," > ").humanize}</th>"
      end
      html += "<th #{rowspan} >Actions</th>"
      html += "</tr><tr>"
      nested_attributes.keys.sort.each do |prefix|
        nested_attributes[prefix].each do |value|
          html += "<th>#{value.humanize}</th>"
        end
      end
      html << "</tr>"
    end
  end
  
  # Method that return a nested_columns_hash from attributes array
  # attributes that return nested atributes into a formated hash
  # -Collections are discarded to avoid problems
  #  with data formating
  #
  def generate_nested_resources_hash(nested_attributes)
    criteria_hash = {}
    nested_attributes.each do |attribute_with_prefix|
      attribute = attribute_with_prefix.split(".").last
      attribute_prefix = attribute_with_prefix.chomp(".#{attribute}")
      if criteria_hash.keys.include?(attribute_prefix)
        criteria_hash[attribute_prefix] << attribute  unless criteria_hash[attribute_prefix].include?(attribute)
      else       
        contain_collections = !attribute_prefix.split(".").select(&:plural?).empty?
        criteria_hash = criteria_hash.merge( attribute_prefix => [ attribute ] ) unless contain_collections
      end
    end
    return criteria_hash
  end
  
  # Method that generate table_cells containing values according to table headers
  # collection => objects returned by the search engine
  #
  def generate_results_table_cells(collection, direct_attributes, nested_attributes=[])
    html = ""
    collection.each do |object|
      html += "<tr>"
      # direct attributes
      direct_attributes.each do |attribute|
        data = format_date(object.send(attribute)) if object.respond_to?(attribute)
        html += "<td>#{data || "-"}</td>" 
      end
      # nested_attributes
      nested_attributes.sort.each do |attribute|
        nested_data = object
        attribute.join(".").split(".").each do |element|
          if nested_data.respond_to?(element)
            nested_data = nested_data.send(element)
          else
            nested_data = "-"
          end
        end
        html += "<td>#{nested_data || '-'}</td>"
      end
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
    result = {}
    model.search_index[:attributes].merge(model.search_index[:additional_attributes]).each_pair do |key, value|
      result = result.merge(key.to_s.humanize => value)
    end
    result 
  end
  
  # method to generate a hash that contain all relationships and their own relationships
  # for a model according to that model's include_array
  #
  def generate_relationships_hash(include_array,parent_model,ancestor=nil,relationship="")
    result = {}
    ancestor ||= parent_model
    include_array.each do |element|      
      if element.is_a?(Hash)
        element.each do |key, value|
          model = parent_model.constantize.association_list[key][:class_name]        
          (result["#{ancestor}#{relationship}"]||=[]) << ["#{parent_model}.#{key.to_s.humanize}", model]       
          result = result.merge(generate_relationships_hash(value, model, parent_model, ".#{key.to_s.humanize}"))
        end
      else
        model = parent_model.constantize.association_list[element][:class_name]
        (result["#{ancestor}#{relationship}"]||=[]) << ["#{parent_model}.#{element.to_s.humanize}", model]
      end
    end
    return result
  end
  
end
