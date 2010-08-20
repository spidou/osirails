require File.dirname(__FILE__) + '/../thirds_test'

class LegalFormTest < ActiveSupport::TestCase
  should_belong_to :third_type
  should_validate_presence_of :name
end
