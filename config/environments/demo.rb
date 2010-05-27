# Settings specified here will take precedence over those in config/environment.rb

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

# FIXME Remove this line at Rails 2.3 upgrading
# With Rails 2.2, this hack is necessary, explanations: 
# https://rails.lighthouseapp.com/projects/8994/tickets/802-eager-load-application-classes-can-block-migration 
# http://www.whatcodecraves.com/articles/2009/03/17/rails_2.2.2_chicken_and_egg_migrations_headache/
config.cache_classes = (File.basename($0) == "rake" && !ARGV.grep(/db:/).empty?) ? false : true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
