# Load application configuration
begin
  FeatureManager.loaded_feature_paths.each do |feature_path|
    Dir.glob(File.join(feature_path, "config", "queries", "*.yml")).each do |yml_path|
      HasSearchIndex.load_page_options_from(yml_path)
    end
  end
  require 'search_controller'
rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError, Exception => e
  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  RAKE_TASK ? puts(error) : raise(e)
end
