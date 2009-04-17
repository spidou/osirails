require 'test_helper'

class NumberTypeTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'NumberType.count' do
      number_type = NumberType.create
      assert_not_nil number_type.errors.on(:name), "A NumberType should have a name"
    end
  end
end