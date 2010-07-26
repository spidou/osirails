require File.dirname(__FILE__) + '/../sales_test'

class MockupTypeTest < ActiveSupport::TestCase
  should_have_many :mockups
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
end
