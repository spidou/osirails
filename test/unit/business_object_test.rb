require 'test/test_helper'

class BusinessObjectTest < ActiveSupport::TestCase
  should_validate_uniqueness_of :name
end
