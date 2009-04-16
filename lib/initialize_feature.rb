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



    
  rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError => e
    error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
    RAKE_TASK ? puts(error) : raise(error)
  end
end
