require File.join(directory, '../initialize.rb')
init(config, directory)

require 'yaml'
yaml = YAML.load(File.open(directory + '/config.yml'))

require 'step_initialize'
begin
  StepInitialize::initialize_step(yaml)
rescue ActiveRecord::StatementInvalid => e
  puts "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
end