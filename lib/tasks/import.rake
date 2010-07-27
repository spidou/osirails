require 'csv'
require 'importer'

namespace :osirails do
  namespace :db do
    desc "Import all data from CSV files for whole project"
    task :import => :environment do
      errors = $ordered_features_path.collect do |feature_path|
        feature_name = feature_path.split("/").last
        import_task = "osirails:#{feature_name}:db:import"
        feature = Feature.find_by_name(feature_name)
        puts "==== Running #{import_task} ===="
        if feature and ( !feature.installed? or !feature.activated? )
          puts "Skip this file because feature is not installed or activated"
          nil
        else
          begin
            Rake::Task[import_task].invoke
            nil
          rescue => e
            import_task
          end
        end
      end.compact
      abort "Errors running #{errors.to_sentence}!" if errors.any?
    end
  end
end
