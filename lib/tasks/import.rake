require 'csv'
require 'importer'

namespace :osirails do
  namespace :db do
    desc "Import all data from CSV files for whole project"
    task :import => :environment do
      tasks = FeatureManager.loaded_feature_paths.map{|path| path.split("/").last}.map{|name| "osirails:#{name}:db:import"}
      errors = tasks.select{ |task| Rake::Task[task] rescue false }.collect do |task| # select tasks which really exist
        puts "==== Running #{task} ===="
        begin
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
