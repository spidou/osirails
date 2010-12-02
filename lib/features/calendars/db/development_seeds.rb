require 'lib/seed_helper'

User.create_missing_calendars # for john.doe and jane.doe

# default events for admin calendar
Event.create! :calendar_id => User.find_by_username("admin").calendar.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
Event.create! :calendar_id => User.find_by_username("admin").calendar.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.day,  :end_at => DateTime.now + 1.day + 2.hours

# default event for john.doe calendar
Event.create! :calendar_id => User.find_by_username("john.doe").calendar.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours

Calendar.all.each do |object|
  object.permissions.each do |permission|
    permission.permissions_permission_methods.each do |object_permission|
      object_permission.update_attribute(:active, true)
    end
  end
end

set_default_permissions
