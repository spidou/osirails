require 'validates_persistence_of'

I18n.load_path += Dir[ File.join(File.dirname(__FILE__), 'config', 'locale', '*.{rb,yml}') ]
I18n.reload!
