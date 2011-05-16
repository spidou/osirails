namespace :osirails do
  namespace :calendars do
    namespace :db do
      Rake::SeedTask.new(:populate) do |t|
        t.seed_files = [ "#{File.dirname(__FILE__)}/../db/seeds.rb", "#{File.dirname(__FILE__)}/../db/development_seeds.rb" ]
        t.verbose = true
      end
      Rake::Task['osirails:calendars:db:populate'].comment = "Load default data AND development data for calendars feature"
      
      Rake::SeedTask.new(:load_default_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:db:load_default_data'].comment = "Load default data for calendars feature"
      
      Rake::SeedTask.new(:load_development_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/development_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:db:load_development_data'].comment = "Load development data for calendars feature"
      
      Rake::SeedTask.new(:load_production_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/production_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:db:load_production_data'].comment = "Load production data for calendars feature"
    end
  end
end
