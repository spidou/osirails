require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, "has_permissions")

Dir.glob(File.join(File.dirname(__FILE__), "app", "models", "*_permission.rb")).each do |permission_file|
  require permission_file
end

require 'has_permissions'
