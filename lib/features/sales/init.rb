require File.join(directory, '../initialize.rb')
init(config, directory)

require 'yaml'
yaml = YAML.load(File.open(directory + '/config.yml'))

require 'step_initialize'
StepInitialize::initialize_step(yaml)