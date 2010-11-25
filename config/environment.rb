# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# -- commented line since Rails freeze
# RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Specifies if the application is launch from a rake task or not (set at TRUE in Rakefile)
RAKE_TASK = false unless defined? RAKE_TASK

# Specifies if the application is launch for testing or not (set in test/test_helper.rb)
TESTING_FEATURE = false unless defined? TESTING_FEATURE

# Specifies if the application is launch for loading data (**/db/*seeds.rb) or not (set in lib/seed_helper.rb)
SEEDING_FEATURE = false unless defined? SEEDING_FEATURE

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'rails_hacks'
require 'contextual_menu'
require 'mysql'
require 'feature_manager'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [:acts_as_watchable, :acts_as_tree, :acts_as_list, :acts_as_taggable_on_steroids, :acts_as_versioned, :tiny_mce,
                    :validates_persistence_of, :paperclip, :journalization, :auto_complete, :local_auto_complete,
                    :has_permissions, :has_search_index, :has_documents, :has_address, :has_numbers, :has_contacts,
                    :has_reference, :acts_as_step, :pdf_generator, :validates_timeliness, :all]
  
  FeatureManager.update_config_plugins(config)
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
  
  config.plugin_paths = Dir["#{RAILS_ROOT}/{lib,vendor}/{features,plugins}"]
  
  config.action_mailer.perform_deliveries = false

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'
  
  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_Osirails_session',
    :secret      => '75a9a52b2fb9337d3dbbb3939d1b054c73aef5adf24b0d8e197b2de8dc169f0ff8147d3ac3b725ba82b545146d49618bfffefb6657897fdf52a325db77bc4f9e',
  }
  
  # Rails default value is false
  config.active_record.timestamped_migrations = true

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.gem 'json', :version => '1.4.6'
  config.gem 'RedCloth', :version => '4.2.3'
  config.gem 'htmlentities', :version => '4.2.1'
  config.gem 'mysql', :version => '2.8.1'
end

require 'version'

# ApplicationHelper can be overrided anywhere, so we (re)load the class everytime the load the environment
# to be sure to remove old references to unexistant methods (after disabling a feature for example)
load 'application_helper.rb' if Rails.env.development? # only with development mode, because in production mode this load cancel all feature's overrides (in lib/features/[feature]/overrides.rb) and there are not loaded again

require 'json'
require 'htmlentities'
## RMagick installation : sudo apt-get install imagemagick librmagick-ruby1.8 librmagick-ruby-doc libfreetype6-dev xml-core -y
