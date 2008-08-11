require 'yaml'
yaml = YAML.load(File.open(directory+'/config.yml'))
puts yaml[name]
require File.join(directory, '../initialize.rb')
init(yaml, config, directory)
