def detect_feature_from_caller(caller)
  dirs = caller.first.split("/")
  feature_name = dirs.include?("features") ? dirs[dirs.index("features")+1] : ''
end

SEEDING_FEATURE = detect_feature_from_caller(caller) unless defined? SEEDING_FEATURE

RAKE_TASK = true # seed may not be run without rake...

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

def set_default_permissions
  %W{ BusinessObject Menu DocumentType }.each do |klass|
    klass.constantize.all.each do |object|
      object.permissions.each do |permission|
        permission.permissions_permission_methods.each do |object_permission|
          object_permission.update_attribute(:active, true)
        end
      end
    end
  end
end
