class WatchableSchedule
  
  def self.execute_function (unity)
    watchables = Watchable.all
    for watchable in watchables
      for function in watchable.on_schedule_watchable_functions
        watchable.has_watchable.deliver_email_for(function, watchable) if function.time_unity == unity
      end
    end
  end
   
end
