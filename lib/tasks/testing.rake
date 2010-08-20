override_task :test do
  errors = %w(test:units test:functionals test:integration).collect do |task|
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
  Rake.application.remove_task("test:units")
  Rake::TestTask.new(:units) do |t|
    t.libs << "test"
    t.pattern = "test/unit/*_test.rb"
    t.verbose = true
  end
  Rake::Task['test:units'].comment = "Run the unit tests"
  
  Rake.application.remove_task("test:functionals")
  Rake::TestTask.new(:functionals) do |t|
    t.libs << "test"
    t.pattern = "test/functional/*_test.rb"
    t.verbose = true
  end
  Rake::Task['test:functionals'].comment = "Run the functional tests"
  
  Rake.application.remove_task("test:integration")
  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.pattern = "test/integration/*_test.rb"
    t.verbose = true
  end
  Rake::Task['test:integration'].comment = "Run the integration tests"
end

namespace :osirails do
  desc "Run all unit, functional and integration tests for whole project (with features and plugins)"
  task :test do
    errors = %w(test osirails:features:test osirails:plugins:test).collect do |task|
      begin
        puts "==== Running #{task} ===="
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.to_sentence}!" if errors.any?
  end
  
  namespace :test do
    desc "Run unit tests for whole project (with features and plugins)"
    task :units do
      errors = %w(test:units osirails:features:test:units osirails:plugins:test:units).collect do |task|
        begin
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
    
    desc "Run functional tests for whole project (with features and plugins)"
    task :functionals do
      errors = %w(test:functionals osirails:features:test:functionals osirails:plugins:test:functionals).collect do |task|
        begin
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
    
    desc "Run integration tests for whole project (with features and plugins)"
    task :integration do
      errors = %w(test:integration osirails:features:test:integration osirails:plugins:test:integration).collect do |task|
        begin
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
  end
  
  namespace :features do
    desc "Run all unit, functional and integration tests for all features"
    task :test do
      tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/features/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test"}
      errors = tasks.collect do |task|
        begin
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
    
    namespace :test do
      desc "Run unit tests for all features"
      task :units do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/features/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:units"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
      
      desc "Run functional tests for all features"
      task :functionals do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/features/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:functionals"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
      
      desc "Run integration tests for all features"
      task :integration do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/features/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:integration"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
    end
  end
  
  
  namespace :plugins do
    desc "Run all unit, functional and integration tests for all plugins"
    task :test do
      tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/plugins/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test"}
      errors = tasks.collect do |task|
        begin
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
          nil
        rescue => e
          task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
    
    namespace :test do
      desc "Run unit tests for all plugins"
      task :units do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/plugins/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:units"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
      
      desc "Run functional tests for all plugins"
      task :functionals do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/plugins/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:functionals"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
      
      desc "Run integration tests for all plugins"
      task :integration do
        tasks = Dir.glob("#{RAILS_ROOT}/{lib,vendor}/plugins/*").map{|path| path.split("/").last}.map{|name| "osirails:#{name}:test:integration"}
        errors = tasks.collect do |task|
          begin
            puts "==== Running #{task} ===="
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end
    end
  end
end
