class Search

  include Permissible
  
  # method to generate an array containing the result array headers ( in the view )
  def self.search_result_headers(hash)
    columns ||= []
    hash.each_pair do |attribute,type|
      if type.class == Hash
        columns = columns.fusion(search_result_headers(type))
      else
        columns << attribute 
      end
    end  
    return columns
  end  
  
  # methode that return in an array the hiearchie of keys into recursives hashes and put a "_" in front of the attribute 
  def self.get_attribute_hierarchie(hash,attribute)
    hash.each_pair do |key,element|
      tab = []
      if element.class == Hash
      
        key.camelize == key ? tab = get_attribute_hierarchie(element,attribute) : tab = get_attribute_hierarchie(element,attribute).fusion([key])
        return tab if tab.include?("_"+attribute)
      elsif key==attribute and element.class != Hash
        return ["_"+key]
      end
    end
    return []
  end
  
  
  # method to get the :include hash in the find
  def self.get_include_hash(hash)
    result_values = []
    hash.each_pair do |model,categories|
      categories.each_value do |attributes|
        result_values = sub_resources(attributes) unless sub_resources(attributes).nil?
      end
    end
    return result_values
  end
  
  # recursive methode used by get_incude_hash
  def self.sub_resources(attributes)
    sub_resources_array = []
    attributes.each_pair do |attribute,contents|
      if contents.class == Hash
        contents.each_value do |value|
          sub_resources(value).nil? ? sub_resources_array << attribute.to_sym : sub_resources_array << {attribute.to_sym => sub_resources(value)}  
        end
      end
    end
    sub_resources_array==[] ?  nil : sub_resources_array
  end
   
  def self.get_conditions_array(criteria_hash) 
    conditions_array ||= []
    
    criteria_hash.each_value do |criterion|
      
    end
    
  end
  
end
