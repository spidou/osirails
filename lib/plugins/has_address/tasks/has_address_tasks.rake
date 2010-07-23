namespace :osirails do
  namespace :has_address do
    desc "Run all unit, functional and integration tests for has_address feature"
    task :test do
      errors = %w(osirails:has_address:test:units osirails:has_address:test:functionals osirails:has_address:test:integration).collect do |task|
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
      Rake::TestTask.new(:units => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_address:test:units'].comment = "Run the has_address unit tests"
      
      Rake::TestTask.new(:functionals => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_address:test:functionals'].comment = "Run the has_address functional tests"
      
      Rake::TestTask.new(:integration => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_address:test:integration'].comment = "Run the has_address integration tests"
    end
  end
end
