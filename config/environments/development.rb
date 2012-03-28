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

# Cache store
#config.cache_store = :memory_store
#config.cache_store = :file_store, '/path/to/cache'
#config.cache_store = :mem_cache_store
config.cache_store = :mem_cache_store, { :namespace => 'development' }
#config.cache_store = :mem_cache_store, '123.456.78.9:1001', '123.456.78.9:1002'

# Bullet configuration (uncomment block to activate Bullet)
#config.after_initialize do
#  Bullet.enable = true
#  Bullet.alert = false
#  Bullet.bullet_logger = true
#  Bullet.console = true
#  Bullet.growl = false
#  #Bullet.xmpp = { :account => 'bullets_account@jabber.org',
#  #                :password => 'bullets_password_for_jabber',
#  #                :receiver => 'your_account@jabber.org',
#  #                :show_online_status => true }
#  Bullet.rails_logger = false
#  Bullet.disable_browser_cache = true
#end

# Don't care if the mailer can't send
#config.action_mailer.raise_delivery_errors = false

### Mail configuration to use with sendmail
#config.action_mailer.delivery_method = :sendmail
#config.action_mailer.smtp_settings = {
#  :address => "smtp.mobius.re",
#  :port => 25,
#  :domain => 'www.mobius.re'
#}
#
#config.action_mailer.perform_deliveries = true 
#config.action_mailer.raise_delivery_errors = true
#config.action_mailer.default_charset = "utf-8"
#config.action_mailer.default_content_type = "text/html"
#config.action_mailer.default_mime_version = "1.0"
#config.action_mailer.default_implicit_parts_order = [ "text/html", "text/plain"]
###
