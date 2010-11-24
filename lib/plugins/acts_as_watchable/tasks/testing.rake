namespace :acts_as_watchable do
  desc "Run all plugin, unit, functional, and integration tests for acts_as_watchable plugin"
  task :test do
    errors = %w(acts_as_watchable:test:plugin acts_as_watchable:test:units acts_as_watchable:test:functionals acts_as_watchable:test:integration).collect do |task|
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
      t.pattern = "#{File.dirname(__FILE__)}/../test/acts_as_watchable_test.rb"
      t.verbose = true
    end
    Rake::Task['acts_as_watchable:test:plugin'].comment = "Run the acts_as_watchable plugin tests"

    Rake::TestTask.new(:units) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
      t.verbose = true
    end
    Rake::Task['acts_as_watchable:test:units'].comment = "Run the acts_as_watchable unit tests"

    Rake::TestTask.new(:functionals) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
      t.verbose = true
    end
    Rake::Task['acts_as_watchable:test:functionals'].comment = "Run the acts_as_watchable functional tests"

    Rake::TestTask.new(:integration) do |t|
      t.libs << "test"
      t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
      t.verbose = true
    end
    Rake::Task['acts_as_watchable:test:integration'].comment = "Run the acts_as_watchable integration tests"
  end
end
