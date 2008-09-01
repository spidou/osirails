require 'acts_as_file'

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::File
end
