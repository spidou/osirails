# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require "#{RAILS_ROOT}/vendor/plugins/override_rake_task/lib/override_rake_task.rb"

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# this global constant permits to specify if we are in rake task context or not
# if we are in a rake task context, we are more tolerant and don't raise exception (just displaying errors)
# when a database or a table doesn't exist
RAKE_TASK = true

Dir.glob("#{RAILS_ROOT}/{lib,vendor}/{features,plugins}/*/tasks/*.rake").each do |rake_file|
  import rake_file
end
