namespace :osirails do
  namespace :logistics do
    desc "Run all unit, functional and integration tests for logistics feature"
    task :test do
      errors = %w(osirails:logistics:test:units osirails:logistics:test:functionals osirails:logistics:test:integration).collect do |task|
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
      Rake::Task['osirails:logistics:test:units'].comment = "Run the logistics unit tests"
      
      Rake::TestTask.new(:functionals => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:logistics:test:functionals'].comment = "Run the logistics functional tests"
      
      Rake::TestTask.new(:integration => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:logistics:test:integration'].comment = "Run the logistics integration tests"
    end
  end
end
