RAILS_ROOT = File.dirname(__FILE__) + '/../../../..'  unless defined?(RAILS_ROOT)
RAILS_ENV  = 'test'
$LOAD_PATH << File.dirname(__FILE__)

require 'test/unit'
require 'boot' unless defined?(ActiveRecord)
require 'active_record'

# Load main library
$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'has_search_index'

require 'lib/activerecord_test_case'

# Load models
path = File.join(File.dirname(__FILE__), '..', 'app', 'models')
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths.unshift(path)

# Manage gems
require 'rubygems'
gem 'shoulda'
require 'shoulda'
gem 'paperclip'
require 'paperclip'

# Osirails initializers
$LOAD_PATH << "#{ RAILS_ROOT }/config/initializers"
require "basics_overrides"
require "shoulda_macros"

# Define logger for has_search_index
log_file = "#{ RAILS_ROOT }/log/test.log"
ActiveRecord::Base.logger = Logger.new(log_file)
