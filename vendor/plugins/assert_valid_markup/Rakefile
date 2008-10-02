task :default => [:test]

PKG_NAME = "assert_valid_markup"
PKG_VERSION = "0.1"

task :docs do
  sh "rdoc lib"
end

task :package => :docs do
  sh "tar czf #{PKG_NAME}-#{PKG_VERSION}.tar.gz *"
end

#task :test do
#  sh "cd test; ruby assert_valid_markup_test.rb"
#end
