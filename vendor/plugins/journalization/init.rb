require 'actor'
require 'subject'
require 'actor_setting'

%w{ models helpers }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)  
  $LOAD_PATH << path 
  dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
  dep.load_paths << path 
  dep.load_once_paths.delete(path)
end

ActionController::Base.prepend_view_path(File.join(File.dirname(__FILE__), 'app', 'views'))

if defined?(I18n)
  I18n.load_path += Dir[ File.join(File.dirname(__FILE__),'lib', 'locale', '*.{rb,yml}') ]
  I18n.reload!
end
