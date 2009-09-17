require 'test/test_helper'

class NumberTest < ActiveSupport::TestCase
  fixtures :numbers

  def setup
    @number = numbers(:normal)
  end

  def test_presence_of_number
    assert_no_difference 'Number.count' do
      number = Number.create
      assert_not_nil number.errors.on(:number), "A Number should have a number"
    end
  end

  def test_presence_of_indicative_id
    assert_no_difference 'Number.count' do
      number = Number.create
      assert_not_nil number.errors.on(:indicative_id), "A Number should have am indicative id"
    end
  end

  def test_presence_of_number_type_id
    assert_no_difference 'Number.count' do
      number = Number.create
      assert_not_nil number.errors.on(:number_type_id), "A Number should have a number type id"
    end
  end

  def test_presence_of_has_number_type
    assert_no_difference 'Number.count' do
      number = Number.create
      assert_not_nil number.errors.on(:has_number_type), "A Number should have a number type"
    end
  end

  def test_format_of_number
    @number.update_attributes(:number => '1234')
    assert_not_nil @number.errors.on(:number), "A Number should be compose by 10 integer"
  end
end
