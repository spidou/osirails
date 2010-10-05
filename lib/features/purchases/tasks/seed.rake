namespace :osirails do
  namespace :purchases do
    namespace :db do
      Rake::SeedTask.new(:populate) do |t|
        t.seed_files = [ "#{File.dirname(__FILE__)}/../db/seeds.rb", "#{File.dirname(__FILE__)}/../db/development_seeds.rb" ]
        t.verbose = true
      end
      Rake::Task['osirails:purchases:db:populate'].comment = "Load default data AND development data for purchases feature"
      
      Rake::SeedTask.new(:load_default_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:purchases:db:load_default_data'].comment = "Load default data for purchases feature"
      
      Rake::SeedTask.new(:load_development_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/development_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:purchases:db:load_development_data'].comment = "Load development data for purchases feature"
    end
  end
end
