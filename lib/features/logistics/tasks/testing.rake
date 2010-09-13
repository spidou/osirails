namespace :osirails do
  namespace :logistics do
    desc "Run all unit, functional and integration tests for logistics feature"
    task :test do
      %w(osirails:logistics:test:units osirails:logistics:test:functionals osirails:logistics:test:integration).collect do |task|
        Rake::Task[task].invoke
      end
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:logistics:test:units'].comment = "Run the logistics unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:logistics:test:functionals'].comment = "Run the logistics functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:logistics:test:integration'].comment = "Run the logistics integration tests"
    end
  end
end
