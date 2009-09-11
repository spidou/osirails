module HasSearchIndexMethodsHelper
  
  def main_model(params)
    model = contextual_search?(params) ? params[:contextual_search][:model] : params[:model]
    HasSearchIndex::MODELS.include?(model) ? model.constantize : nil
  end
  
  # Method to prepare the criteria hash to be passed as argument to the 'search_with' method.
  #
  # == Arguments : params:Hash
  # == Return    : Hash (criteria) like {"name" => {:value => "toto", :action => "like"}, :search_type => 'or'}
  #
  def prepare_criteria_for_contextual_search(params)
    searched_value = params[:contextual_search][:value].strip
    errors         = manage_contextual_search_errors(params)
    criteria       = {:search_type => 'or'}
    
    unless errors[:wrong_model]
      main_model = params[:contextual_search][:model].constantize
      YAML.load(params[:contextual_search][:options]).each do |attribute_path|
        model = get_model_from(attribute_path, main_model)
        if attribute_path.last == "*"
          attribute_path = attribute_path.gsub("*","")
          model.search_index[:attributes].each_key { |attribute| criteria.merge!(attribute_path + attribute => searched_value) }
        else
          criteria.merge!(attribute_path => searched_value)
        end
      end
      return criteria
    else
      return nil
    end
  end
  
  # Method to get a model from a path
  #
  # ==== examples:
  #
  #  # get_model_from("job_contract.name")
  #  #=> JobContract
  #
  #  # get_model_from("job_contract.job_contract_type.name")
  #  #=> JobContractType
  #
  #  # get_model_from("job_contract.custom_relationship_to_target_job_contract_type_class.name")
  #  #=> JobContractType
  #
  #  # get_model_from("first_name")
  #  #=> nil
  #
  def get_model_from(path, model)
    return model unless path.include?(".")
    
    elements_array = path.split(".")
    elements_array.pop
    elements_array.each {|relationship| model = model.association_list[relationship.to_sym][:class_name].constantize}   
    model
  end
  
  # Method to prepare the criteria hash to be passed as argument to the 'search_with' method.
  #
  # == Arguments : params:Hash
  # == Return    : Hash (criteria) like {"name" => {:value => "toto", :action => "like"}, :search_type => 'or'}
  #
  def prepare_criteria_for_search(params)     
    unless params[:criteria].nil?
      criteria = {:search_type => params['search_type']}
      model    = params[:model].constantize
      
      params[:criteria].each_value do |criterion|
        attribute = criterion['attribute']
        data_type = criterion['action'].split(",")[0]
        opt_hash  = {:value => model.format_value(criterion, data_type), :action => criterion['action'].split(",")[1]}
        if criteria.keys.include?(attribute)
          criteria[attribute] << opt_hash
        else
          criteria.merge!( attribute =>[ opt_hash ] )                                # put the opt_hash into an array to manage multiple attributes 
        end
      end
      return criteria
    else
      return []
    end
  end

  # Method to know the search context
  # 
  # #=> return 'true' if it's a contextual search and 'false' if not
  #
  def contextual_search?(params)
    !params[:contextual_search].nil?
  end
  
  # Method to call the search plugin
  #
  def search(model, criteria)
    # criteria.each{ |key,value| criteria[key] = value.split(" ") }
    unless model.nil?
      return model.search_with(criteria)  # if criteria is nil search_with return all records like model.all
    else
      return []
    end
  end
  
  # Method that add a flash error to the session if there is errors into the
  # 'params' passed as arguments.
  #
  # == Arguments : params:Hash
  # == Return    : Boolean
  #
  def manage_contextual_search_errors(params)
    errors  = YAML.load(params[:contextual_search][:errors])
    message = "Le moteur de recherche contextuel de cette page contient une erreur. Merci de signaler le problème à votre administrateur."
    flash.now[:error] = message if errors[:wrong_model] or !errors[:wrong_attributes].empty?
    return errors
  end
  
end
