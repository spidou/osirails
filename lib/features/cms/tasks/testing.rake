namespace :osirails do
  namespace :cms do
    desc "Run all unit, functional and integration tests for cms feature"
    task :test do
      errors = %w(osirails:cms:test:units osirails:cms:test:functionals osirails:cms:test:integration).collect do |task|
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
      Rake::Task['osirails:cms:test:units'].comment = "Run the cms unit tests"
      
      Rake::TestTask.new(:functionals => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:test:functionals'].comment = "Run the cms functional tests"
      
      Rake::TestTask.new(:integration => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:test:integration'].comment = "Run the cms integration tests"
    end
  end
end
