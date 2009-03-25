# this code permits to constantize all models which are in features (lib/features/**/app/models)
#   just like those are in app/models

begin
  unless !defined?(ACTIVATED_FEATURES_PATH)
    (ACTIVATED_FEATURES_PATH).each do |feature_path|
      Dir.glob(File.join(feature_path, "app", "models", "*.rb")).each do |model|
        if File.exists?(model)
          class_name = File.basename(model).chomp(File.extname(model)).camelize
          class_name.constantize rescue raise NameError, "uninitialized constant #{class_name} in file #{model}"
        end
      end
    end
  end
rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError => e
  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  RAKE_TASK ? puts(error) : raise(error)
end
