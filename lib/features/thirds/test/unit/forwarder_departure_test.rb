require File.dirname(__FILE__) + '/../thirds_test'

class ForwarderDepartureTest < ActiveSupport::TestCase
  should_belong_to :forwarder, :departure
  should_validate_presence_of :forwarder, :with_foreign_key => :default
end
