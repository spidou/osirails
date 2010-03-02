require 'test/test_helper'

class MissingElementTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'MissingElement.count' do
      missing_element = MissingElement.create
      assert_not_nil missing_element.errors.on(:name),
        "A MissingElement should have a name"
    end
  end

  def test_presence_of_orders_steps_id
    assert_no_difference 'MissingElement.count' do
      missing_element = MissingElement.create
      assert_not_nil missing_element.errors.on(:orders_steps_id),
        "A MissingElement should have an orders steps id"
    end
  end
end
