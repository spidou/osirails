require File.dirname(__FILE__) + '/../calendars_test'

class CalendarTest < ActiveSupport::TestCase
  def setup
    @good_calendar = calendars(:normal_calendar)
    
    @calendar = Calendar.new
    @calendar.valid?
  end

  def test_belongs_to_user
    assert_equal @good_calendar.user, users(:calendar_user),
      "This Calendar should belongs to this User"
  end
  

  def test_has_many_events
    @good_calendar.events.each do |event|
      assert event.class == Event, "This Calendar should have many Events"
    end
  end

  def test_has_many_event_categories
    assert_equal @good_calendar.event_categories, [event_categories(:normal_event_category)],
      "This Calendar should have this EventCategory"
  end

  def test_events_at_period
    # TODO Test the method events_at_period
  end

  def test_events_at_date
    @good_calendar.events_at_date(Date.today) do |event|
      assert ((event.start_at.to_date <= Date.today) and
        (event.end_at.to_date >= Date.today)),
        "This Calendar return wrong Events at the specified date"
    end
  end

  def test_alarms_at_date
    # TODO First code the method in calendar.rb
  end
  
  def test_presence_of_user
    assert !@calendar.errors.invalid?(:user_id), "user_id should be valid"
    
    @calendar.user_id = -1
    @calendar.valid?
    assert !@calendar.errors.invalid?(:user_id), "user_id should be valid"
    assert @calendar.errors.invalid?(:user), "user should NOT be valid because user_id refers to a wrong user"
    
    @calendar.user_id = users(:calendar_user).id
    @calendar.valid?
    assert !@calendar.errors.invalid?(:user_id), "user_id should be valid"
  end
  
  def test_presence_of_name
    assert @calendar.errors.invalid?(:name), "name should NOT be valid because it's empty"
    
    @calendar.name = "string"
    @calendar.valid?
    assert !@calendar.errors.invalid?(:name), "name should be valid"
  end
  
  def test_uniqueness_of_name
    @calendar.name = "string"
    @calendar.valid?
    assert !@calendar.errors.invalid?(:name), "name should be valid"
    
    flunk "@calendar should be saved" unless @calendar.save!
    
    @new_calendar = Calendar.new(:name => "string")
    @new_calendar.valid?
    
    assert @new_calendar.errors.invalid?(:name), "name should NOT be valid because the name is already taken"
  end
end
