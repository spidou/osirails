require 'test/test_helper'

class ToolEventTest < ActiveSupport::TestCase

  def setup
    @good_tool_event = tool_events(:good_tool_event)
    flunk "good_tool_event should be valid #{@good_tool_event.errors.inspect}" unless @good_tool_event.valid?
    
    @tool_event = ToolEvent.new
    @tool_event.valid?
  end
  
  def teardown
    @good_tool_event = nil
    @tool_event = nil
  end
  
  def test_inclusion_of_event_type
    [1,2].each do |type|
      @tool_event.event_type = type
      @tool_event.valid?
      assert !@tool_event.errors.invalid?(:event_type), "event_type should be valid"
    end
    [0,12,-1].each do |bad_type|
      @tool_event.event_type = bad_type
      @tool_event.valid?
      assert @tool_event.errors.invalid?(:event_type), "event_type should NOT be valid because it should be included into [1,2]"
    end
  end
  
  def test_inclusion_of_status_with_type_intervention
    @tool_event.event_type = ToolEvent::INTERVENTION
    [0,1].each do |status|
      @tool_event.status = status
      @tool_event.valid?
      assert !@tool_event.errors.invalid?(:status), "status should be valid"
    end
    [2,-1,12].each do |bad_status|
      @tool_event.status = bad_status
      @tool_event.valid?
      assert @tool_event.errors.invalid?(:status), "status should NOT be valid because it should be included into [1,2]"
    end
  end
  
  def test_inclusion_of_status_with_type_incident
    @tool_event.event_type = ToolEvent::INCIDENT
    [0,1,2].each do |status|
      @tool_event.status = status
      @tool_event.valid?
      assert !@tool_event.errors.invalid?(:status), "status should be valid"
    end
    [3,-1,12].each do |bad_status|
      @tool_event.status = bad_status
      @tool_event.valid?
      assert @tool_event.errors.invalid?(:status), "status should NOT be valid because it should be included into [1,2]"
    end
  end
  
  def test_presence_of_end_date
    @tool_event.event_type = ToolEvent::INCIDENT
    @tool_event.valid?
    assert !@tool_event.errors.invalid?(:end_date), "end_date should be valid because type is INCIDENT"
    
    @tool_event.event_type = ToolEvent::INTERVENTION
    @tool_event.valid?
    assert @tool_event.errors.invalid?(:end_date), "end_date should NOT be valid because it's nil and type is INTERVENTION"
    
    assert !@good_tool_event.errors.invalid?(:end_date), "end_date should be valid"
  end
  
  def test_presence_of_start_date
    assert @tool_event.errors.invalid?(:start_date), "start_date should NOT be valid because it's nil"
    assert !@good_tool_event.errors.invalid?(:start_date), "start_date should be valid"
  end
  
  def test_presence_of_comment
    assert @tool_event.errors.invalid?(:comment), "comment should NOT be valid because it's nil"
    assert !@good_tool_event.errors.invalid?(:comment), "comment should be valid"
  end
  
  def test_presence_of_name
    assert @tool_event.errors.invalid?(:name), "name should NOT be valid because it's nil"
    assert !@good_tool_event.errors.invalid?(:name), "name should be valid"
  end
  
  def test_presence_of_tool
    assert @tool_event.errors.invalid?(:tool_id), "tool_id should NOT be valid because it's nil"
    
    @tool_event.tool_id = 0
    @tool_event.valid?
    assert !@tool_event.errors.invalid?(:tool_id), "tool_id should be valid"
    assert @tool_event.errors.invalid?(:tool), "tool should NOT be valid because tool_id is wrong"
    
    assert !@good_tool_event.errors.invalid?(:tool_id), "tool_id should be valid"
    assert !@good_tool_event.errors.invalid?(:tool), "tool should be valid"
  end
  
  def test_presence_of_event
    assert !@tool_event.errors.invalid?(:event_id), "event_id should be valid because nil is allowed to permit 'event' creation while 'tool_event' create"
    
    @tool_event.event_id = 0
    @tool_event.valid?
    assert !@tool_event.errors.invalid?(:event_id), "event_id should be valid"
    assert @tool_event.errors.invalid?(:event), "event should NOT be valid because event_id is wrong"
    
    assert !@good_tool_event.errors.invalid?(:event_id), "event_id should be valid"
    assert !@good_tool_event.errors.invalid?(:event), "event should be valid"
  end
  
  def test_presence_of_internal_actor
    assert @tool_event.errors.invalid?(:internal_actor_id), "internal_actor_id should NOT be valid because it's nil"
    
    @tool_event.internal_actor_id = 0
    @tool_event.valid?
    assert !@tool_event.errors.invalid?(:internal_actor_id), "internal_actor_id should be valid"
    assert @tool_event.errors.invalid?(:internal_actor), "internal_actor should NOT be valid because internal_actor_id is wrong"
    
    assert !@good_tool_event.errors.invalid?(:internal_actor_id), "internal_actor_id should be valid"
    assert !@good_tool_event.errors.invalid?(:internal_actor), "internal_actor should be valid"
  end
  
  def test_persistence_of_event_type
    assert !@good_tool_event.errors.invalid?(:event_type), "event_type should be valid because event_type still the same"
    
    @tool_event.event_type = ToolEvent::INCIDENT
    @tool_event.valid?
    assert !@tool_event.errors.invalid?(:event_type), "event_type should be valid because tool_event is a new record"
    
    @good_tool_event.event_type = ToolEvent::INCIDENT
    @good_tool_event.valid?
    assert @good_tool_event.errors.invalid?(:event_type), "event_type should NOT be valid because the tool_event is not a new record and event_type has changed"
  end
  
  def test_validates_date_is_correct
    [:start_date, :end_date].each do |attribute|
      assert !@good_tool_event.errors.invalid?(attribute), "#{attribute} should be valid"
    end
    
    # two dates are equals
    @tool_event.start_date = Date.today
    @tool_event.end_date = Date.today
    @tool_event.valid?
    [:start_date, :end_date].each do |attribute|
      assert !@tool_event.errors.invalid?(attribute), "#{attribute} should be valid"
    end
    
    # start_date is greater than end_date
    @tool_event.start_date = Date.today
    @tool_event.end_date = Date.yesterday
    @tool_event.valid?
    [:start_date, :end_date].each do |attribute|
      assert @tool_event.errors.invalid?(attribute), "#{attribute} should NOT be valid"
    end
  end
  
  def test_calendar_duration
    @tool_event.event_type = ToolEvent::INCIDENT
    assert_equal nil, @tool_event.calendar_duration, "calendar_duration should be nil"
    
    @tool_event.event_type = ToolEvent::INTERVENTION
    # when start_date == nil and end_date == nil
    assert_equal 0, @tool_event.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date or end_date == nil
    @tool_event.start_date = Date.today
    assert_equal 0, @tool_event.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date == end_date
    @tool_event.end_date = @tool_event.start_date
    assert_equal 1, @tool_event.calendar_duration, "calendar_duration should be equal to 1"
    
    # when start_date > end_date
    @tool_event.end_date = Date.today - 1.day
    assert_equal 0, @tool_event.calendar_duration, "calendar_duration should be equal to 0"
    
    # when start_date < end_date
    @tool_event.end_date = Date.today + 1.day
    assert_equal 2, @tool_event.calendar_duration, "calendar_duration should be equal to 2"
  end
  
  def test_named_scope_effectives
    base = ToolEvent.count
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    flunk "tool should be valid" unless @tool_event.save
    assert_equal base + 1, ToolEvent.count, "the number of events should be equal to #{base + 1}"
    assert_equal base + 1, ToolEvent.effectives.count, "the number of effectives events should be equal to #{base + 1}, because the last event added is effective"
    
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.start_date = Date.tomorrow
    flunk "tool should be valid" unless @tool_event.save
    assert_equal base + 2, ToolEvent.count, "the number of events should be equal to #{base + 2}"
    assert_equal base + 1, ToolEvent.effectives.count, "the number of effectives events should be equal to #{base + 1}, because the last event added is future"
  end
  
  def test_validates_tool_is_not_scrapped
    assert !@good_tool_event.errors.invalid?(:tool_id), "tool_id should be valid because there's no event with SCRAPPED status"
    
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.attributes = {:event_type => ToolEvent::INCIDENT, :status => ToolEvent::SCRAPPED}
    flunk "tool_event shoul be valid #{@tool_event.errors.inspect}" unless @tool_event.save
    
    @tool_event.valid?
    assert @tool_event.errors.invalid?(:tool_id), "tool_id should NOT be valid because there's an event with SCRAPPED status"
  end
  
  def test_event
    @tool_event.attributes = @good_tool_event.attributes
    flunk "tool_event shoul be valid #{@tool_event.errors.inspect}" unless @tool_event.save
    event_for_test_id = @tool_event.event.id # event is generated when tool_event is saved thank's to a callback
    
    # test event create with callback
    assert_nothing_raised( ActiveRecord::RecordNotFound ) { Event.find event_for_test_id }
    
    # test dependent delete
    @tool_event.destroy
    assert_raise( ActiveRecord::RecordNotFound ) { Event.find event_for_test_id }
  end
  
  # TODO uncomment the two commented lines when the method prepare_event will affect 'end_date' to 'end_at'
  def test_update_event
    assert_equal @good_tool_event.start_date.to_datetime, @good_tool_event.event.start_at, "tool_event's start_date should be equal with event's start_at"
#    assert_equal @good_tool_event.end_date.to_datetime, @good_tool_event.event.end_at, "tool_event's end_date should be equal with event's end_at"
    assert_equal @good_tool_event.name, @good_tool_event.event.title, "tool_event's start_date should be equal with event's title"
    
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.attributes = {:start_date => Date.yesterday, :end_date => Date.tomorrow.next, :name => 'new name'}
    flunk "tool_event should be valid  #{@tool_event.errors.inspect}" unless @tool_event.save
    
    assert_equal @tool_event.start_date.to_datetime, @tool_event.event.start_at, "tool_event's start_date should be equal with event's start_at"
#    assert_equal @tool_event.end_date.to_datetime, @tool_event.event.end_at, "tool_event's end_date should be equal with event's end_at"
    assert_equal @tool_event.name, @tool_event.event.title, "tool_event's name should be equal with event's title"
  end
end
