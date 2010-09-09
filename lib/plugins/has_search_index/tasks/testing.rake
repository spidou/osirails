namespace :osirails do
  namespace :has_search_index do
    desc "Run all unit, functional, integration and library tests for has_search_index feature"
    task :test do
      errors = %w(osirails:has_search_index:test:units osirails:has_search_index:test:functionals osirails:has_search_index:test:integration osirails:has_search_index:test:library).collect do |task|
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
      desc "Run the has_search_index library tests"
      task :library do
        FileUtils.cd(File.dirname(__FILE__) + '/../test')
        exec('rake test')
      end
      
      Rake::TestTask.new(:units => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:units'].comment = "Run the has_search_index unit tests"
      
      Rake::TestTask.new(:functionals => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:functionals'].comment = "Run the has_search_index functional tests"
      
      Rake::TestTask.new(:integration => :environment) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:has_search_index:test:integration'].comment = "Run the has_search_index integration tests"
    end
  end
end
