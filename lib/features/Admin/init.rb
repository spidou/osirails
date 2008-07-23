# Feature Admin

# Load every file in the app directory
controller_path = File.join(directory, 'app', 'controllers')
$LOAD_PATH << controller_path
Dependencies.load_paths << controller_path
config.controller_paths << controller_path
ActionController::Base.append_view_path(File.dirname(__FILE__) + '/app/views/')
$LOAD_PATH << File.join(directory, 'app', 'helpers')
$LOAD_PATH << File.join(directory, 'app', 'models')
