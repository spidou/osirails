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
  
  def test_named_scope_ordered
    #TODO test_named_scope_ordered
  end
  
  def test_named_scope_effectives
    base = ToolEvent.count
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.save!
    flunk "tool should be saved" if @tool_event.new_record?
    
    assert_equal base + 1, ToolEvent.count, "the number of events should be equal to #{base + 1}"
    assert_equal base + 1, ToolEvent.effectives.count, "the number of effectives events should be equal to #{base + 1}, because the last event added is effective"
    
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.start_date = Date.tomorrow
    @tool_event.save!
    flunk "tool should be saved" if @tool_event.new_record?
    
    assert_equal base + 2, ToolEvent.count, "the number of events should be equal to #{base + 2}"
    assert_equal base + 1, ToolEvent.effectives.count, "the number of effectives events should be equal to #{base + 1}, because the last event added is future"
  end
  
  def test_named_scope_scheduled
    #TODO test_named_scope_scheduled
  end
  
  def test_named_scope_currents
    #TODO test_named_scope_currents
  end
  
  def test_named_scope_last_three
    #TODO test_named_scope_last_three
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
    assert_equal @good_tool_event.start_date.to_datetime, @good_tool_event.event.start_at, "tool_event's start_date should be equal to event's start_at"
#    assert_equal @good_tool_event.end_date.to_datetime, @good_tool_event.event.end_at, "tool_event's end_date should be equal to event's end_at"
    assert_equal @good_tool_event.title, @good_tool_event.event.title, "tool_event's title should be equal to event's title"
    
    @tool_event = ToolEvent.new(@good_tool_event.attributes)
    @tool_event.attributes = {:start_date => Date.yesterday, :end_date => Date.tomorrow.next, :name => 'new name'}
    flunk "tool_event should be valid #{@tool_event.errors.inspect}" unless @tool_event.save
    
    assert_equal @tool_event.start_date.to_datetime, @tool_event.event.start_at, "tool_event's start_date should be equal to event's start_at"
#    assert_equal @tool_event.end_date.to_datetime, @tool_event.event.end_at, "tool_event's end_date should be equal to event's end_at"
    assert_equal @tool_event.title, @tool_event.event.title, "tool_event's title should be equal to event's title"
  end
  
  def test_prepare_event_callback
    tool_event = ToolEvent.new(@good_tool_event.attributes)
    assert_nil tool_event.event, "event should NOT exist yet"
    
    tool_event.valid?
    assert_not_nil tool_event.event, "event should exist after validation"
    assert tool_event.event.new_record?, "event should NOT be saved in database"
    
    assert_event_values_matches_with_tool_event(tool_event)
  end
  
  def test_prepare_event_callback_with_alarm
    tool_event = ToolEvent.new(@good_tool_event.attributes.merge({:alarm_attributes => [{:do_alarm_before => 120, :description => "description", :email_to => "test@test.com" }]}))
    # alarm_attributes= call prepare_event
    assert_not_nil tool_event.event, "event should exist because 'prepare_event' is called by alarm_attributes="
    
    tool_event.valid?
    assert_not_nil tool_event.event, "event should exist after validation"
    assert tool_event.event.new_record?, "event should NOT be saved in database"
    
    assert_equal 1, tool_event.event.alarms.size, "event should have 1 alarm"
    assert tool_event.event.alarms.first.new_record?, "alarm should NOT be saved in database"
  end
  
  def test_save_event_callback
    tool_event = prepare_tool_event
    
    assert tool_event.save, "tool_event should be saved > #{tool_event.errors.inspect}"
    assert !tool_event.event.new_record?, "event should be saved"
    
    assert_event_values_matches_with_tool_event(tool_event)
  end
  
  def test_save_event_callback_with_alarm
    tool_event = prepare_tool_event(:alarm_attributes => [{:do_alarm_before => 120, :description => "description", :email_to => "test@test.com" }])
    flunk "event should have 1 alarm" unless tool_event.event.alarms.size == 1
    
    assert tool_event.save, "tool_event should be saved > #{tool_event.errors.inspect}"
    assert !tool_event.event.alarms.first.new_record?, "alarm should be saved"
  end

  def test_modify_end_date_callback_for_incident
    tool_event            = ToolEvent.new(@good_tool_event.attributes)
    
    # Without predefined end_date
    tool_event.end_date   = nil
    tool_event.event_type = ToolEvent::INCIDENT
    tool_event.valid?
    
    assert_equal tool_event.start_date, tool_event.end_date, "end_date should be equal to start_date"
    
    # With wrong predefined end_date
    tool_event.end_date   = tool_event.start_date + 1 
    tool_event.event_type = ToolEvent::INCIDENT
    tool_event.valid?
    
    assert_equal tool_event.start_date, tool_event.end_date, "end_date should be equal to start_date"
  end
  
  private
    def prepare_tool_event(attributes = {})
      tool_event = ToolEvent.new(@good_tool_event.attributes.merge(attributes))
      tool_event.valid?
      flunk "tool_event should have 1 unsaved event" unless tool_event.event and tool_event.event.new_record?
      return tool_event
    end
    
    def assert_event_values_matches_with_tool_event(tool_event)
      calendar = Calendar.find_or_create_by_name("equipments_calendar")
      values = { :calendar_id   => calendar.id,
                 :full_day      => true,
                 :start_at      => tool_event.start_date.to_datetime,
                 :end_at        => tool_event.start_date.to_datetime,
                 :title         => tool_event.title,
                 :description   => tool_event.comment,
                 :organizer_id  => tool_event.internal_actor_id }
      
      values.each do |attribute, value|
        assert_equal value, tool_event.event.send(attribute), "event attribute '#{attribute}' should be equal to '#{value}'"
      end
    end
end
