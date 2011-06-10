require File.dirname(__FILE__) + '/../logistics_test'

class ToolTest < ActiveSupport::TestCase
  
  should_have_many :tool_events
  
  should_belong_to :service, :job, :employee, :supplier
  
  should_validate_presence_of :name, :purchase_date, :serial_number
  should_validate_presence_of :service, :with_foreign_key => :default
  
  #validates_presence_of :service,  :if => :service_id
  #validates_presence_of :job,      :if => :job_id
  #validates_presence_of :employee, :if => :employee_id
  #validates_presence_of :supplier, :if => :supplier_id
  
  should_validate_numericality_of :purchase_price
  
  should_journalize :identifier_method => :name_and_serial_number

  def setup
    @good_tool = tools(:good_tool)
    @good_tool.tool_events = []
    flunk "good_tool should be valid #{@good_tool.errors.inspect}" unless @good_tool.valid?
    
    @tool = Tool.new
    @tool.valid?
  end
  
  subject{ @tool }
  
  def teardown
    @good_tool = nil
    @tool      = nil
  end
  
  def test_status_with_incident_today
    [ToolEvent::AVAILABLE, ToolEvent::UNAVAILABLE].each do |status|
      add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, status)
      assert_equal status, @good_tool.status, "tool status should be equal to current event's status"
    end
    
    # Verify that unavailable status has priority
    add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, ToolEvent::AVAILABLE)
    assert_equal ToolEvent::UNAVAILABLE, @good_tool.status, "tool status should be UNAVAILABLE because there's an event with UNAVAILABLE status the same day"
    
    add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert_equal ToolEvent::SCRAPPED, @good_tool.status, "tool status should be Scrapped because the scrapped status is definitive even if the event is finished"
  end
  
  def test_status_with_incident_yesterday
    [ToolEvent::AVAILABLE, ToolEvent::UNAVAILABLE].each do |status|
      add_tool_event(@good_tool, Date.yesterday, ToolEvent::INCIDENT, status)
      assert_equal ToolEvent::AVAILABLE, @good_tool.status, "tool status should be Available because the event is finished"
    end

    add_tool_event(@good_tool, Date.yesterday, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert_equal ToolEvent::SCRAPPED, @good_tool.status, "tool status should be Scrapped because the scrapped status is definitive even if the event is finished"
  end
  
  def test_status_with_scheduled_scrapped_event
    add_tool_event(@good_tool, Date.tomorrow, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert_equal ToolEvent::AVAILABLE, @good_tool.status, "tool status should NOT be Scrapped because the incident is scheduled"
  end
  
  def test_status_with_last_event_finishing_today
    [ToolEvent::AVAILABLE, ToolEvent::UNAVAILABLE].each do |status|
      add_tool_event(@good_tool, Date.today, ToolEvent::INTERVENTION, status)
      assert_equal status, @good_tool.status, "tool status should be equal to current event's status"
    end
    
    # Verify that unavailable status has priority
    add_tool_event(@good_tool, Date.today, ToolEvent::INTERVENTION, ToolEvent::AVAILABLE)
    assert_equal ToolEvent::UNAVAILABLE, @good_tool.status, "tool status should be UNAVAILABLE because there's an event with UNAVAILABLE status the same day"
  end
  
  def test_status_with_last_event_finishing_yesterday   
    [ToolEvent::AVAILABLE, ToolEvent::UNAVAILABLE].each do |status|
      add_tool_event(@good_tool, Date.yesterday, ToolEvent::INTERVENTION, status)
      assert_equal ToolEvent::AVAILABLE, @good_tool.status, "tool status should be Available because the event is finished"
    end
  end
  
  def test_can_be_edited
    assert @good_tool.can_be_edited?, "can_be_edited should return true"
    
    add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert !@good_tool.can_be_edited?, "can_be_edited should return false because status is SCRAPPED"
  end
  
  def test_validates_edit
    assert @good_tool.valid?, "good_tool should be valid because it hasn't got a SCRAPPED event"
    
    @tool = Tool.new(@good_tool.attributes)
    assert @tool.valid?, "tool should be valid because it's a new record"
    
    add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert !@good_tool.valid?, "good_tool should NOT be valid because it has one SCRAPPED event"
  end
  
  def test_has_one_scrapped
    assert !@good_tool.has_one_scrapped?, "has_one_scrapped? should be false because good_tool has no event with SCRAPPED status"
    
    add_tool_event(@good_tool, Date.today, ToolEvent::INCIDENT, ToolEvent::SCRAPPED)
    assert @good_tool.has_one_scrapped?, "has_one_scrapped? should be true because good_tool has an event with SCRAPPED status"
  end
  
  private
  
    def add_tool_event(tool, date, event_type, status)
      tool_event = ToolEvent.new(:name => 'tool_test', :event_type => event_type,
                                 :start_date => date, :end_date => date,
                                 :tool_id => tool.id, :status => status,
                                 :internal_actor_id => Employee.first.id,
                                 :comment => "comment")
      flunk "event should be valid #{tool_event.errors.inspect} #{tool_event.event.errors.inspect}" unless tool_event.save
      tool.reload
      tool_event
    end
     
end
