require 'acts_as_file'

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::File
end

## This block is use because Document.add_model is call only when model is use
files = Dir.glob("**/**/**/app/models/*.rb")

files.each do |file|
  file.split("/").last.chomp(".rb").camelize.constantize
end

