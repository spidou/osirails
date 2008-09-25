class Search

  include Permissible
  
  # method to generate an array containing the result array headers ( in the view )
  def self.search_result_headers(hash, parent)
    columns ||= []
    hash.each_pair do |attribute,type|
      if type.class == Hash
        attribute.camelize = attribute ? columns = columns.fusion(search_result_headers(type,attribute)) : columns = columns.fusion(search_result_headers(type))
      else
        parent != model ? columns << [parent, attribute]  : columns << attribute 
      end
    end  
    return columns
  end  
  
  # methode that return in an array the hiearchie of keys into recursives hashes and put a "_" in front of the attribute 
  # hash = an array containing all attributes
  # attribute = the attribute that you want the hierarchy  
  def self.get_attribute_hierarchy(hash,attribute,parent)
    hash.each_pair do |key,element|
      tab = []
      if element.class == Hash
        key.camelize == key ? sub_model = key : sub_model = parent 
        key.camelize == key ? tab = get_attribute_hierarchy(element,attribute,key) : tab = get_attribute_hierarchy(element,attribute,parent).fusion([key])
        return tab if tab.include?("_"+attribute) and parent == sub_model
      elsif key==attribute 
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
   
  def self.get_conditions_array(criteria_hash,model,search_type) 
    conditions_array ||= [""]
    criteria_hash.each_value do |criterion|
      if search_type == "and"
        conditions_array[0].blank? ? group="" : group = " and "
      elsif search_type == "or"
        conditions_array[0].blank? ? group="" : group = " or "
      elsif search_type == "not"
        conditions_array[0].blank? ? group="" : group = " and "
        criterion['action'] = negative(criterion['action'])
      else
        group = ""
      end  
      criterion['parent']==model ? parent = " " : parent = criterion['parent'].tableize + "."
      conditions_array[0] += group + parent + criterion['attribute'].split(",")[0] + " " + criterion['action'] + "?" 
      conditions_array << format_value(criterion)
    end 
    return conditions_array
  end
  
  def self.negative(action)
    positive = ["=",">","<",">=","<=","like"]
    negative = ["!=","<",">","<=",">=","not like"]
    return negative[positive.index(action)] if positive.include?(action)
    return positive[negative.index(action)] if negative.include?(action)
  end
  
  def self.format_value(params)
    case params['attribute'].split(",")[1]
      when 'date'
        m= params['date(2i)'] 
        d= params['date(3i)'] 
        y= params['date(1i)'] 
        result = "#{y}/#{m}/#{d}"
      when 'number'
        result =params['value'].to_d
      else
        result = "%" + params['value'] + "%"
    end
    return result
  end
  
end
