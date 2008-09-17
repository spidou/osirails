class CalendarPermission < ActiveRecord::Base
  belongs_to :role
  belongs_to :calendar
end
