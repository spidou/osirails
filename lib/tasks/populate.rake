namespace :osirails do
  namespace :db do
    desc "Populate database with default data and development data (only use for development)"
    task :populate => [ :load_default_data, :load_development_data ]
  end
end

namespace :osirails do
  namespace :db do
    desc "Populate the database with simple entries in simple tables"
    task :load_default_data => :environment do
      ([RAILS_ROOT] + FeatureManager.loaded_feature_paths).each do |feature_path|
        feature_name = feature_path.split("/").last
        seed_path = File.join(feature_path, "db", "seeds.rb")
        puts "====== Loading default data from #{seed_path} ======"
        if File.exists?(seed_path)
          require seed_path
        else
          puts "File not found : #{seed_path}"
        end
      end
    end
  end
end

namespace :osirails do
  namespace :db do
    desc "Populate the database with simple entries (only use for development)"
    task :load_development_data => :environment do
      ([RAILS_ROOT] + FeatureManager.loaded_feature_paths).each do |feature_path|
        feature_name = feature_path.split("/").last
        seed_path = File.join(feature_path, "db", "development_seeds.rb")
        puts "====== Loading development data from #{seed_path} ======"
        if File.exists?(seed_path)
          require seed_path
        else
          puts "File not found : #{seed_path}"
        end
      end
    end
  end
end
