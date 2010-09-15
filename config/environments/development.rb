# Settings specified here will take precedence over those in config/environment.rb
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Mail configuration
#config.action_mailer.delivery_method = :sendmail
#config.action_mailer.smtp_settings = {
#  :adresse => "smtp.mobius.re",
#  :port => 25,
#  :domain => 'www.mobius.re'
#}

#config.action_mailer.perform_deliveries = true 
#config.action_mailer.raise_delivery_errors = true
#config.action_mailer.default_charset = "utf-8"
#config.action_mailer.default_content_type = "text/html"
#config.action_mailer.default_mime_version = "1.0"
#config.action_mailer.default_implicit_parts_order = [ "text/html", "text/plain"]

