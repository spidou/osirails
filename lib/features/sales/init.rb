require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
if conf = init(config, directory) and conf.feature.activated?
  require File.join(directory, '../sales/lib/step_initialize.rb')
  step_initialize(directory)
end
