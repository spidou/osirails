require File.dirname(__FILE__) + '/../thirds_test'

class ThirdTypeTest < ActiveSupport::TestCase
  should_have_many :legal_forms
  should_validate_presence_of :name
end
