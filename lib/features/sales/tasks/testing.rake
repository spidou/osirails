namespace :osirails do
  namespace :sales do
    desc "Run all unit, functional and integration tests for sales feature"
    task :test do
      errors = %w(osirails:sales:test:units osirails:sales:test:functionals osirails:sales:test:integration).collect do |task|
        begin
          Rake::Task[task].invoke
          nil
        rescue => e
          { :task => task, :error => e }
        end
      end.compact
      abort "#{errors.map{ |h| "Errors running #{h[:task]}\nMessage: #{h[:error].message}\nBacktrace:\n####\n#{h[:error].backtrace.join("\n")}\n####" }.join("\n")}" if errors.any?
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:sales:test:units'].comment = "Run the sales unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:sales:test:functionals'].comment = "Run the sales functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:sales:test:integration'].comment = "Run the sales integration tests"
    end
  end
end
