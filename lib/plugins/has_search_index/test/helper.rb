require 'test/unit'
require 'boot' unless defined?(ActiveRecord)
require 'active_record'

# define logger for has_search_index
log_file = File.dirname(__FILE__) + '/../../../../log/test.log'
ActiveRecord::Base.logger = Logger.new(log_file)
