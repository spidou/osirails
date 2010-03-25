namespace :osirails do
  namespace :db do
    desc "Populate database with default data and development data (only use for development)"
    task :populate => [ :load_default_data, :load_development_data ]
  end
end
