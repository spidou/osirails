class WatchingSchedule
  
  def self.execute_function(unity)
    Watching.all.each do |watching|
      watching.on_schedule_watchable_functions.find(:all, :conditions => ["time_unity = ?", unity]).each do |function|
        watching.watchable.deliver_email_for(function, watching)
      end
    end
  end
  
end
