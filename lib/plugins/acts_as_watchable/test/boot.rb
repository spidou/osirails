version = ENV['RAILS_VERSION'] || "2.2.3"
version = nil if version and version == ""

require 'rubygems'

if version
  puts "using Rails#{version ? ' ' + version : nil} gems"
  gem 'rails', version
else
  gem 'actionpack'
  gem 'activerecord'
end

require 'active_record'
require 'active_support'
require 'action_mailer'
