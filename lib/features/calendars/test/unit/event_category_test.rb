require 'test_helper'

class EventCategoryTest < ActiveSupport::TestCase
  def setup
    @event_category = EventCategory.create(:calendar_id => 1,
                                           :name => 'Foo')
  end

  def test_presence_of_calendar_id
    assert_no_difference 'EventCategory.count' do
      event_category = EventCategory.create
      assert_not_nil event_category.errors.on(:calendar_id),
        "An EventCategory should have a calendar id"
    end
  end

  def test_presence_of_name
    assert_no_difference 'EventCategory.count' do
      event_category = EventCategory.create
      assert_not_nil event_category.errors.on(:name),
        "An EventCategory should have a name"
    end
  end

  def test_uniqness_of_name
    assert_no_difference 'EventCategory.count' do
      event_category = EventCategory.create(:name => @event_category.name)
      assert_not_nil event_category.errors.on(:name),
        "An EventCategory should have an uniq name"
    end
  end
end
