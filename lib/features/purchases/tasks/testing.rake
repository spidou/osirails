namespace :osirails do
  namespace :purchases do
    desc "Run all unit, functional and integration tests for purchases feature"
    task :test do
      %w(osirails:purchases:test:units osirails:purchases:test:functionals osirails:purchases:test:integration).collect do |task|
        Rake::Task[task].invoke
      end
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:purchases:test:units'].comment = "Run the purchases unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:purchases:test:functionals'].comment = "Run the purchases functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:purchases:test:integration'].comment = "Run the purchases integration tests"
    end
  end
end
