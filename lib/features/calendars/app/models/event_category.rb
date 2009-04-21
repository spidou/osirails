class EventCategory < ActiveRecord::Base
  # Relationships
  belongs_to :calendar

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def self.find_all_shared
    self.find_all_by_calendar_id(nil)
  end
  
  def self.find_all_accessible(cal)
    self.find_all_shared + (cal.event_categories.nil? ? [] : cal.event_categories)
  end
end
