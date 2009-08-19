require 'test/test_helper'

class ThirdTypeTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'ThirdType.count' do
      third_type = ThirdType.create
      assert_not_nil third_type.errors.on(:name), "A Third Type should have a name"
    end
  end
end
