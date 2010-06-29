# default calendars and events
calendar1 = Calendar.create! :user_id => User.first.id, :name => "Calendrier par défaut de Admin", :color => "red", :title => "Titre du calendrier"
Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 1", :description => "Description de l'evenement 1", :start_at => DateTime.now,          :end_at => DateTime.now + 4.hours
Event.create! :calendar_id => calendar1.id, :title => "Titre de l'evenement 2", :description => "Description de l'evenement 2", :start_at => DateTime.now + 1.day,  :end_at => DateTime.now + 1.day + 2.hours

# default calendar
#calendar_john_doe = Calendar.create! :user_id => john.user.id, :name => "Calendrier de John doe", :color => "blue", :title => "Calendrier de John Doe"
#Event.create! :calendar_id => calendar_john_doe.id, :title => "Titre de l'evenement", :description => "Description de l'evenement", :start_at => DateTime.now, :end_at => DateTime.now + 4.hours
