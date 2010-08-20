require 'csv'
require 'importer'

namespace :osirails do
  namespace :db do
    desc "Import all data from CSV files for whole project"
    task :import => :environment do
      errors = FeatureManager.loaded_feature_paths.collect do |feature_path|
        feature_name = feature_path.split("/").last
        import_task = "osirails:#{feature_name}:db:import"
        puts "==== Running #{import_task} ===="
        begin
          Rake::Task[import_task].invoke
          nil
        rescue => e
          import_task
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
  end
end
