# Permit to define env variables with :env accessor at call time (origin will_paginate)
#
class EnvTestTask < Rake::TestTask
  attr_accessor :env

  def ruby(*args)
    env.each { |key, value| ENV[key] = value } if env
    super
    env.keys.each { |key| ENV.delete key } if env
  end
end

namespace :osirails do
  namespace :has_search_index do
    desc "Run all unit, functional, integration and library tests for has_search_index feature"
    task :test do
      errors = %w(osirails:has_search_index:test:units osirails:has_search_index:test:functionals osirails:has_search_index:test:integration osirails:has_search_index:test:library).collect do |task|
        begin
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
    
    namespace :test do
      EnvTestTask.new(:library) do |t|
        t.pattern = "#{File.dirname(__FILE__)}/../test/library/*_test.rb"
        t.verbose = true
        t.env = { 'DB' => 'mysql' }
        t.libs << 'test'
      end                             
      
      EnvTestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.env = { 'DB' => 'mysql' }
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:units'].comment = "Run the has_search_index unit tests"
      
      EnvTestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.env = { 'DB' => 'mysql' }
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:functionals'].comment = "Run the has_search_index functional tests"
      
      EnvTestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.env = { 'DB' => 'mysql' }
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:integration'].comment = "Run the has_search_index integration tests"
    end
  end
end
