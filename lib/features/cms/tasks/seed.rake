namespace :osirails do
  namespace :cms do
    namespace :db do
      Rake::SeedTask.new(:populate) do |t|
        t.seed_files = FileList["#{File.dirname(__FILE__)}/../db/*seeds.rb"].reverse
        t.verbose = true
      end
      Rake::Task['osirails:cms:db:populate'].comment = "Load default data AND development data for cms feature"
      
      Rake::SeedTask.new(:load_default_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:db:load_default_data'].comment = "Load default data for cms feature"
      
      Rake::SeedTask.new(:load_development_data) do |t|
        t.seed_files = "#{File.dirname(__FILE__)}/../db/development_seeds.rb"
        t.verbose = true
      end
      Rake::Task['osirails:cms:db:load_development_data'].comment = "Load development data for cms feature"
    end
  end
end
