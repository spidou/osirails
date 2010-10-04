module Rails
  def root
    File.dirname(__FILE__)
  end
end

include Rails

RAILS_ROOT = Rails.root

$LOAD_PATH << File.dirname(__FILE__)

require 'test/unit'
require 'boot' unless defined?(ActiveRecord)

require 'active_record'
require 'active_support'
#include I18n
require 'action_mailer'

require File.join(File.dirname(__FILE__), 'lib', 'activerecord_test_case')
require File.join(File.dirname(__FILE__), '..', 'lib', 'notifier_mailer')
require File.join(File.dirname(__FILE__), '..', 'lib', 'watchable_schedule')

ActionController::Base.prepend_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')
ActionController::Base.prepend_view_path File.join(File.dirname(__FILE__), 'fixtures', 'views')

ActionMailer::Base.template_root  = File.join(File.dirname(__FILE__), 'fixtures', 'views') 
ActionMailer::Base.delivery_method = :test

path = File.join(File.dirname(__FILE__), '..', 'app', 'models')   
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths << path 
dep.load_once_paths.delete(path)

require 'rubygems'
require 'ruby-debug'
gem 'thoughtbot-shoulda'
require 'shoulda'

gem 'paperclip'
require 'paperclip'
include Paperclip

log_file = File.join(File.dirname(__FILE__), "test.log")
ActiveRecord::Base.logger = Logger.new(log_file)
