# initialize a feature
#   +config+ is the 'config' variable which is instanciate by default in plugin context
#   +path+ is the 'directory' variable which is instanciate by default in plugin context
#   +plugin+ : false means it's a real feature.
#            : "string" means it's a plugin which wants to pretend to be a feature (to instanciate menus in its config.yml file)
#                 the string is mostly the plugin name
def init(config, path, plugin = false)
  begin
    require 'yaml'
    yaml_path = File.join(path, 'config.yml')
    yaml = YAML.load(File.open(yaml_path)) rescue {}
    
    FeatureManager.new(yaml, plugin, config, path)
    
#    ######### SEARCH
#    # test and add search indexes into db
#    error_message = "syntaxe error in '#{name}' yaml."
#
#    def verify_attribute_type(attr_class, type)
#      case attr_class
#        when String
#          return 1 unless type=="string"
#        when Date
#          return 1 unless type=="date"
#        when DateTime
#          return 1 unless type=="date"
#        when Time
#          return 1 unless type=="date"
#        else
#          return 1 unless type=="number"
#      end
#      return 0
#    end
#
#    def verify_sub_resources(hash,error_message)
#      hash.each_pair do |sub_attribute,value|
#        if value.instance_of?(Hash)
#          value.each_pair do |sub_attribute2,value2|
#            if value2.instance_of?(Hash)
#              return verify_sub_resources(value2,error_message) unless verify_sub_resources(value2,error_message).blank?
#            else
#              return "#{ error_message } the attribute '#{ sub_attribute2 }' is incorrect for '#{ sub_attribute }'!" unless sub_attribute.constantize.new.respond_to?(sub_attribute2)
#            end
#          end
#        else
#          return "#{ error_message } missing attribute type or sub attributes hash for  '#{ sub_attribute }' "
#        end
#      end
#      return ""
#    end
#    
#    unless searches.blank? or searches == []
#      searches.each_key do |key|
#        searches[key].each_key do |elmnt|
#          searches[key][elmnt].each_pair do |attr_name,attr_type|
#            if attr_type.instance_of?(Hash)
#              raise verify_sub_resources(attr_type,error_message) unless verify_sub_resources(attr_type,error_message).blank?
#              raise "#{ error_message } The sub resource '#{ attr_name }' is incorrect for '#{ key }'!" unless key.constantize.new.respond_to?(attr_name)
#            else
#              raise "#{ error_message } The attribute '#{ attr_name }' is incorrect for '#{ key }'!" unless key.constantize.new.respond_to?(attr_name)
#            end
#          end
#        end
#      end
#      feature.update_attribute('search', searches)
#    end
#    ######### END SEARCH

    
  rescue ActiveRecord::StatementInvalid, Mysql::Error => e
    error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
    RAKE_TASK ? puts(error) : raise(error)
  end
end
