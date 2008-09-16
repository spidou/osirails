require 'yaml'
yaml = YAML.load(File.open(directory+'/config.yml'))
require File.join(directory, '../initialize.rb')
init(yaml, config, directory)

require File.join(RAILS_ROOT, "lib/features/Calendars/app/models/user.rb")