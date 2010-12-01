# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#every 1.minute do
#  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::MINUTLY_UNITY)", :environment => "development"
#end

every 1.hour do
  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::HOURLY_UNITY)"
end

every 1.day do
  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::DAILY_UNITY)"
end

every 1.week do
  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::WEEKLY_UNITY)"
end

every 1.month do
  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::MONTHLY_UNITY)"
end

# Don't work since we update to whenever 0.6.2
#every 1.year do
#  runner "WatchingSchedule.execute_function(WatchingsWatchableFunction::YEARLY_UNITY)"
#end
