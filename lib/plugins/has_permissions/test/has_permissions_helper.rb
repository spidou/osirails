require 'test/test_helper'

require File.join(File.dirname(__FILE__), 'fixtures', 'classes')

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all
end
