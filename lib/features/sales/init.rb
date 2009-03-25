require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
if init(config, directory).feature.activated?
  require File.join(directory, '../sales/lib/step_initialize.rb')
  step_initialize(directory)
end
