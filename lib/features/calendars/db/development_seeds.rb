require 'lib/seed_helper'

# default calendars and events
calendar1 = Calendar.create! :user_id => User.first.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.day,  :end_at => DateTime.now + 1.day + 2.hours

# default calendar
calendar_john_doe = Calendar.create! :user_id => Employee.find_by_first_name_and_last_name("John", "DOE").user.id, :name => "Calendrier de John DOE", :color => "blue", :title => "Calendrier de John DOE"
Event.create! :calendar_id => calendar_john_doe.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours

Calendar.all.each do |object|
  object.permissions.each do |permission|
    permission.permissions_permission_methods.each do |object_permission|
      object_permission.update_attribute(:active, true)
    end
  end
end
