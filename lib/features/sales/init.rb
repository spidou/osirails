require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
if conf = init(config, directory) and conf.feature.activated?
  StepManager.new(directory)
end

require 'product_base'
