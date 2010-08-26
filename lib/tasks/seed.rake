namespace :osirails do
  
  namespace :db do
    desc "Load default data AND development data for whole project"
    task :populate => [ "osirails:core:db:populate", "osirails:features:db:populate" ]
    
    desc "Load default data for whole project"
    task :load_default_data => [ "osirails:core:db:load_default_data", "osirails:features:db:load_default_data" ]
    
    desc "Load default data AND development data for whole project"
    task :load_development_data => [ "osirails:core:db:load_development_data", "osirails:features:db:load_development_data" ]
  end
  
  namespace :core do
    namespace :db do
      Rake::SeedTask.new(:populate) do |t|
        t.seed_files = [ "db/seeds.rb", "db/development_seeds.rb" ]
        t.verbose = true
      end
      Rake::Task['osirails:core:db:populate'].comment = "Load default data AND development data for the project's core"
      
      Rake::SeedTask.new(:load_default_data) do |t|
        t.seed_files = "db/seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:core:db:load_default_data'].comment = "Load default data for the project's core"
      
      Rake::SeedTask.new(:load_development_data) do |t|
        t.seed_files = "db/development_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:core:db:load_development_data'].comment = "Load development data for the project's core"
    end
  end
  
  namespace :features do
    namespace :db do
      desc "Load default data AND development data for all features"
      task :populate => :environment do
        tasks = FeatureManager.loaded_feature_paths.map{|path| path.split("/").last}.map{|name| "osirails:#{name}:db:populate"}
        tasks.select{ |task| Rake::Task[task] rescue false }.each do |task| # select tasks which really exist
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
        end
      end
      
      desc "Load default data for all features"
      task :load_default_data => :environment do
        tasks = FeatureManager.loaded_feature_paths.map{|path| path.split("/").last}.map{|name| "osirails:#{name}:db:load_default_data"}
        tasks.select{ |task| Rake::Task[task] rescue false }.each do |task| # select tasks which really exist
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
        end
      end
      
      desc "Load development data for all features"
      task :load_development_data => :environment do
        tasks = FeatureManager.loaded_feature_paths.map{|path| path.split("/").last}.map{|name| "osirails:#{name}:db:load_development_data"}
        tasks.select{ |task| Rake::Task[task] rescue false }.each do |task| # select tasks which really exist
          puts "==== Running #{task} ===="
          Rake::Task[task].invoke
        end
      end
    end
  end
  
end
