require 'yaml'
yaml = YAML.load(File.open(directory+'/config.yml'))
require File.join(directory, '../initialize.rb')
init(yaml, config)