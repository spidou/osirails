require File.join(File.dirname(__FILE__), "lib", "has_documents")

# load models, controllers and helpers
%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path) # in development mode, this permits to avoid restart the server after any modifications on these paths (to confirm)
end

# load views
ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), 'app', 'views'))
