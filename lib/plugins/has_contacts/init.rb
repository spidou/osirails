require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, "has_contacts")

require 'has_contacts'

# defines interpolations for paperclip
if Object.const_defined?("Paperclip")
  Paperclip::Attachment.interpolations[:gender] = proc do |attachment, style|
    attachment.instance.gender
  end
else
  raise Exception, "paperclip is required"
end
