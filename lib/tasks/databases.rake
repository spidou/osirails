namespace :db do
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  override_task :migrate => :environment do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    ($ordered_features_path + $all_plugins_path).each do |feature_path|                                                               #
      puts "====== Running migrations inside #{feature_path} ======"                                            # this code has been added to take in account
      ActiveRecord::Migrator.migrate("#{feature_path}/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil) # the features' migrations
    end                                                                                                         #
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end
  
  namespace :migrate do
    desc 'Runs the "up" for a given migration VERSION.'
    override_task :up => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      
      migrated = false                                                            # this code has been added to take in account
      ($ordered_features_path + $all_plugins_path).each do |feature_path|                               # the features' migrations
        puts "====== Running migrations inside #{feature_path} ======"            #
        begin                                                                     #
          ActiveRecord::Migrator.run(:up, "#{feature_path}/db/migrate/", version) #
          migrated = true                                                         #
        rescue ActiveRecord::UnknownMigrationVersionError => e                    #
          puts e.message                                                          #
        end                                                                       #
      end                                                                         #
      begin                                                                       #
        ActiveRecord::Migrator.run(:up, "db/migrate/", version)                   #
      rescue ActiveRecord::UnknownMigrationVersionError => e                      #
        migrated ? puts(e.message) : raise(e)                                     #
      end                                                                         #
      
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    desc 'Runs the "down" for a given migration VERSION.'
    override_task :down => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      
      migrated = false                                                              # this code has been added to take in account
      $ordered_features_path.each do |feature_path|                                 # the features' migrations
        puts "====== Running migrations inside #{feature_path} ======"              #
        begin                                                                       #
          ActiveRecord::Migrator.run(:down, "#{feature_path}/db/migrate/", version) #
          migrated = true                                                           #
        rescue ActiveRecord::UnknownMigrationVersionError => e                      #
          puts e.message                                                            #
        end                                                                         #
      end                                                                           #
      begin                                                                         #
        ActiveRecord::Migrator.run(:down, "db/migrate/", version)                   #
      rescue ActiveRecord::UnknownMigrationVersionError => e                        #
        migrated ? puts(e.message) : raise(e)                                       #
      end                                                                           #
      
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
  
  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  override_task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ( $ordered_features_path.reverse + $all_plugins_path ).each do |feature_path|                   #
      puts "====== Running migrations inside #{feature_path} ======"        # this code has been added to take in account
      ActiveRecord::Migrator.rollback("#{feature_path}/db/migrate/", step)  # the features' migrations
    end                                                                     #
    ActiveRecord::Migrator.rollback('db/migrate/', step)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end
  
  desc "Raises an error if there are pending migrations"
  override_task :abort_if_pending_migrations => :environment do
    if defined? ActiveRecord
      pending_migrations = ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations
      $ordered_features_path.each do |feature_path|                                                             # this code has been added to take in account
        pending_migrations += ActiveRecord::Migrator.new(:up, "#{feature_path}/db/migrate").pending_migrations  # the features' migrations
      end                                                                                                       #

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run "rake db:migrate" to update your database then try again.}
      end
    end
  end
end
