require 'test/test_helper'

class EventCategoryTest < ActiveSupport::TestCase
  fixtures :event_categories, :calendars

  def test_presence_of_name
    assert_no_difference 'EventCategory.count' do
      event_category = EventCategory.create
      assert_not_nil event_category.errors.on(:name),
        "An EventCategory should have a name"
    end
  end

  def test_uniqness_of_name
    assert_no_difference 'EventCategory.count' do
      event_category = EventCategory.create(:name => event_categories(:normal_event_category).name)
      assert_not_nil event_category.errors.on(:name),
        "An EventCategory should have an uniq name"
    end
  end

  def test_find_all_shared
    assert_equal EventCategory.find_all_shared,
      [event_categories(:without_calendar)],
      "EventCategory should return this EventCategory"
  end

  def test_find_all_accessible
    assert_equal EventCategory.find_all_accessible(calendars(:normal_calendar)),
      [event_categories(:without_calendar), event_categories(:normal_event_category)],
      "EventCategory should return this EventCategory"
  end

  def test_belongs_to_calendar
    assert_equal event_categories(:normal_event_category).calendar, calendars(:normal_calendar),
      "This EventCategory should belongs to a calendar"
  end
end
