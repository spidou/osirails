def detect_feature_from_caller(caller)
  dirs = caller.first.split("/")
  feature_name = dirs.include?("features") ? dirs[dirs.index("features")+1] : ''
end

SEEDING_FEATURE = detect_feature_from_caller(caller) unless defined? SEEDING_FEATURE

RAKE_TASK = true # seed may not be run without rake...

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
