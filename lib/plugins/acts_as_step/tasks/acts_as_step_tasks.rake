namespace :osirails do
  namespace :acts_as_step do
    desc "Run all unit, functional and integration tests for acts_as_step feature"
    task :test do
      errors = %w(osirails:acts_as_step:test:units osirails:acts_as_step:test:functionals osirails:acts_as_step:test:integration).collect do |task|
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
      Rake::Task['osirails:acts_as_step:test:units'].comment = "Run the acts_as_step unit tests"
      
      Rake::TestTask.new(:functionals => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:acts_as_step:test:functionals'].comment = "Run the acts_as_step functional tests"
      
      Rake::TestTask.new(:integration => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:acts_as_step:test:integration'].comment = "Run the acts_as_step integration tests"
    end
  end
end
