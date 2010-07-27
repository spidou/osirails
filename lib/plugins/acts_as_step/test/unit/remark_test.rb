require 'test/test_helper'

class RemarkTest < ActiveSupport::TestCase
  should_belong_to :user
  should_validate_presence_of :user_id, :text
end
