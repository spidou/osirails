require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory)

require File.join(directory, '../sales/lib/step_initialize.rb')
step_initialize(directory)
