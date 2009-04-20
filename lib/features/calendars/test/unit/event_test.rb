require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # TODO Do more unit test for Event
  def setup
    @event = Event.create(:title => "Foo",
                          :description => "Bar",
                          :start_at => DateTime.now,
                          :end_at => DateTime.now + 4.hours)
  end

  def test_presence_of_title
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:title), "An Event should have a title"
    end
  end

  def test_presence_of_start_at
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:start_at), "An Event should have a start at date"
    end
  end

  def test_presence_of_end_at
    assert_no_difference 'Event.count' do
      event = Event.create
      assert_not_nil event.errors.on(:end_at), "An Event should have a end at date"
    end
  end
end
