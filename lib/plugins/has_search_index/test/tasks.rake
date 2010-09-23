require 'rake/testtask'

desc 'Test the plugin.(run all tests)'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.libs << 'test'
end

# I want to specify environment variables at call time
# look at +test_with_mysql_database+ for example
# it permit to define env variables with :env accessor
#
class EnvTestTask < Rake::TestTask
  attr_accessor :env

  def ruby(*args)
    env.each { |key, value| ENV[key] = value } if env
    super
    env.keys.each { |key| ENV.delete key } if env
  end
end


EnvTestTask.new :test_with_mysql_database do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.env = { 'DB' => 'mysql' }
  t.libs << 'test'
end

def reset_invoked
  Rake::Task['test'].instance_variable_set '@already_invoked', false
end
