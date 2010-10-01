namespace :journalization do
  desc "Run all plugin, unit, functional, and integration tests for journalization plugin"
  task :test do
    errors = %w(journalization:test:plugin journalization:test:units journalization:test:functionals journalization:test:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.join(' ')}!" if errors.any?
  end

  namespace :test do
    Rake::TestTask.new(:plugin) do |t|
      t.libs << 'test'
      t.pattern = "#{File.dirname(__FILE__)}/../test/journalization_test.rb"
      t.verbose = true
    end
    Rake::Task['journalization:test:plugin'].comment = "Run the journalization plugin tests"

    Rake::TestTask.new(:units) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
      t.verbose = true
    end
    Rake::Task['journalization:test:units'].comment = "Run the journalization unit tests"

    Rake::TestTask.new(:functionals) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
      t.verbose = true
    end
    Rake::Task['journalization:test:functionals'].comment = "Run the journalization functional tests"

    Rake::TestTask.new(:integration) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
      t.verbose = true
    end
    Rake::Task['journalization:test:integration'].comment = "Run the journalization integration tests"
  end
end
