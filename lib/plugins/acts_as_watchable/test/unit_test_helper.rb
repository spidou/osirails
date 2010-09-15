ENV["RAILS_ENV"] = "test"
$LOAD_PATH << File.dirname(__FILE__)

require File.dirname(__FILE__) + '/../../../../config/environment'
require 'boot' unless defined?(ActiveRecord)
require 'shoulda'
require 'lib/activerecord_test_case'

log_file = File.dirname(__FILE__) + '/../../../../log/test.log'
ActiveRecord::Base.logger = Logger.new(log_file)
