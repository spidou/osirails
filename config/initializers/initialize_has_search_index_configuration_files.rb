# Load application configuration

$activated_features_path.each do |feature_path| # FeatureManager.ordered_feature_paths.each do |feature_path| # TODO replace by the comment
  Dir.glob(File.join(feature_path, "**", "config", "queries", "*.yml")).each do |yml_path|
    HasSearchIndex.load_page_options_from(yml_path)
  end
end

require 'has_search_index_initializer'
