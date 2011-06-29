require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('active_counter', '0.1') do |p|
  p.description    = "ActiveCounter provides you a simple way to define counters, to update them and retrieve them."
  p.url            = "http://github.com/spidou/active_counter"
  p.author         = "Mathieu Fontaine"
  p.email          = "spidou@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
