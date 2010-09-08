namespace :osirails do
  namespace :thirds do
    desc "Run all unit, functional and integration tests for thirds feature"
    task :test do
      %w(osirails:thirds:test:units osirails:thirds:test:functionals osirails:thirds:test:integration).collect do |task|
        Rake::Task[task].invoke
      end
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:test:units'].comment = "Run the thirds unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:test:functionals'].comment = "Run the thirds functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:test:integration'].comment = "Run the thirds integration tests"
    end
  end
end
