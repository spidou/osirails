namespace :osirails do
  namespace :thirds do
    namespace :db do
      Rake::SeedTask.new(:populate) do |t|
        t.seed_files = [ "#{File.dirname(__FILE__)}/../db/seeds.rb", "#{File.dirname(__FILE__)}/../db/development_seeds.rb" ]
        t.verbose = true
      end
      Rake::Task['osirails:thirds:db:populate'].comment = "Load default data AND development data for thirds feature"
      
      Rake::SeedTask.new(:load_default_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:db:load_default_data'].comment = "Load default data for thirds feature"
      
      Rake::SeedTask.new(:load_development_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/development_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:db:load_development_data'].comment = "Load development data for thirds feature"
      
      Rake::SeedTask.new(:load_production_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/production_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:thirds:db:load_production_data'].comment = "Load production data for thirds feature"
    end
  end
end
