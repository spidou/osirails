require 'acts_as_watchable'
require 'notifier_mailer'
require 'watchable_schedule'
require 'tls_smtp'

%w{ models controllers }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)  
  $LOAD_PATH << path 
  dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
  dep.load_paths << path 
  dep.load_once_paths.delete(path)
end

ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), 'app', 'views'))
ActionMailer::Base.template_root = ActionController::Base.view_paths

if Rails.env == "test"
  require File.join(File.dirname(__FILE__), "shoulda_macros", "act_as_watchable")
  require File.join(File.dirname(__FILE__), "shoulda_macros", "act_as_watcher")
end

if Object.const_defined?("ActionView")
  ActionView::Base.send(:include, ActsAsWatchablesHelper)
end
