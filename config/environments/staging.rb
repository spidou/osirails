# Settings specified here will take precedence over those in config/environment.rb

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Cache store
#config.cache_store = :memory_store
#config.cache_store = :file_store, '/path/to/cache'
#config.cache_store = :mem_cache_store
config.cache_store = :mem_cache_store, { :namespace => 'staging' }
#config.cache_store = :mem_cache_store, '123.456.78.9:1001', '123.456.78.9:1002'

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
