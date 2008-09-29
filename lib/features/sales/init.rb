require File.join(directory, '../initialize.rb')
init(config, directory)

require File.join(directory, '../sales/lib/step_initialize.rb')
step_initialize(directory)