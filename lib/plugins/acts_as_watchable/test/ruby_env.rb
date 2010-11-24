module Rails
  def root
    File.dirname(__FILE__)
  end
end

include Rails

RAILS_ROOT = Rails.root

$LOAD_PATH << File.dirname(__FILE__)

require 'boot' unless defined?(ActiveRecord)

require 'rubygems'
require 'ruby-debug'
Debugger.settings[:autoeval] = true

require 'test/unit'

gem 'thoughtbot-shoulda', '2.10.2'
require 'shoulda'

gem 'paperclip', '2.2.6'
require 'paperclip'

require File.join(File.dirname(__FILE__), 'lib', 'activerecord_test_case')

# require plugin files
require File.join(File.dirname(__FILE__), '..', 'lib', 'acts_as_watchable')
require File.join(File.dirname(__FILE__), '..', 'lib', 'notification_mailer')
require File.join(File.dirname(__FILE__), '..', 'lib', 'watching_schedule')

# Fixtures
ActionController::Base.prepend_view_path(File.join(File.dirname(__FILE__), '..', 'app', 'views'))
ActionController::Base.prepend_view_path(File.join(File.dirname(__FILE__), 'fixtures', 'views'))

ActionMailer::Base.template_root  = File.join(File.dirname(__FILE__), 'fixtures', 'views') 
ActionMailer::Base.delivery_method = :test

Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')

path = File.join(File.dirname(__FILE__), '..', 'app', 'models')
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths << path 
dep.load_once_paths.delete(path)

# I18n locale path
I18n.load_path += Dir[ File.join(RAILS_ROOT, 'config', 'locale', '*.{rb,yml}') ]

log_file = File.join(File.dirname(__FILE__), "test.log")
ActiveRecord::Base.logger = Logger.new(log_file)
