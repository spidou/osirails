class Search

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
      if contents.class == {}.class
        contents.each_value do |value|
          sub_resources(value).nil? ? sub_resources_array << attribute.to_sym : sub_resources_array << {attribute.to_sym => sub_resources(value)}  
        end
      end
    end
    sub_resources_array==[] ?  nil : sub_resources_array
  end
  
 def self.regroup_attributes(hash)
    result_hash = hash.values[0].merge(hash.values[1])
    #hash.values[1].each_pair do |key,value|
    #  unless value.class=={}
    #    result_hash.merge(hash.values[1])
    #  else
    #    result_hash[key].nil? ? result_hash.merge(values) : result_hash[key].merge(values[key])
    #  end
    #end
    return result_hash
  end
  
end
