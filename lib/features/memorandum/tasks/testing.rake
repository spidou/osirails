namespace :osirails do
  namespace :memorandum do
    desc "Run all unit, functional and integration tests for memorandum feature"
    task :test do
      errors = %w(osirails:memorandum:test:units osirails:memorandum:test:functionals osirails:memorandum:test:integration).collect do |task|
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
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:memorandum:test:units'].comment = "Run the memorandum unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:memorandum:test:functionals'].comment = "Run the memorandum functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:memorandum:test:integration'].comment = "Run the memorandum integration tests"
    end
  end
end
