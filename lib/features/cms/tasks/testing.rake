namespace :osirails do
  namespace :cms do
    desc "Run all unit, functional and integration tests for cms feature"
    task :test do
      %w(osirails:cms:test:units osirails:cms:test:functionals osirails:cms:test:integration).collect do |task|
        Rake::Task[task].invoke
      end
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:test:units'].comment = "Run the cms unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:test:functionals'].comment = "Run the cms functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:test:integration'].comment = "Run the cms integration tests"
    end
  end
end
