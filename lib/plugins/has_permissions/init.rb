require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, "has_permissions")

require 'permission'
require 'permission_method'
require 'permissions_permission_method'

require 'has_permissions'
