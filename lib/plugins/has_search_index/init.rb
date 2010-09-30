FeatureManager.preload(config, directory, "has_search_index")

I18n.load_path += Dir[ File.join(RAILS_ROOT, 'lib', 'plugins', 'has_search_index', 'config', 'locale', '*.{rb,yml}') ]
I18n.reload!

