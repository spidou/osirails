require_dependency 'app/models/user'

class User 
  has_one :calendar
  
  after_create :create_associated_calendar
  
  def self.create_missing_calendars
    User.all.reject(&:calendar).each{ |u| u.send(:create_associated_calendar) }
  end
  
  private
    def create_associated_calendar
      return if calendar
      build_calendar(:name => "Calendrier de #{self.employee_name}", :title => "Calendrier de #{self.employee_name}").save!
    end
end
