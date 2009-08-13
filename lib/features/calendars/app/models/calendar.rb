require 'calendar_permission' # this is necessary, otherwise the plugin 'has_permissions' can't find the CalendarPermission class.

# To resolve a bug time
# refer to: http://dev.rubyonrails.org/ticket/7975
class Date
  def week_of_year
    self.yday / 7 + 1
  end

  alias_method :week, :week_of_year
  alias_method :yweek, :week_of_year
end

# The structure of the Calendar is based on the RFC 2445. It permit to make
# iCalendar format.
# Convert method are based on the Icalendar plugins made by Jeff Rose.
# Describing:
# user_id     Can't be used with name column
# name        Can't be used with user_id column
# color       Hexa color (optinal)
# title       :string
class Calendar < ActiveRecord::Base
  has_permissions
  setup_has_permissions_model
  
  require 'rubygems'
  require 'icalendar'
  require 'date'

  # Relationships
  belongs_to :user
  has_many :events
  has_many :event_categories
 
  # TODO Must be configurable
  # Constants
  PATH_UPLOAD_ICS = "#{RAILS_ROOT}/public"
  PRODUCT_CORP = "E.M.R."
  PRODUCT_NAME = "Osirails 0.1"
  PRODUCT_LANG = "EN"
  TIME_ZONE = "Indian/Reunion"

  # Returns an array of events for every day in a pediod
  def events_at_period(options)
    options[:start_date] ||= Date::today
    options[:end_date] ||= Date::today
    date = options[:start_date]

    return_events = {}
    while date <= options[:end_date]
      return_events[date.to_s] ||= []
      return_events[date.to_s] += events_at_date(date)
      date += 1.day
    end
    return_events
  end

  # Returns an array of events for the specified date
  # arg must be a Date object
  def events_at_date(date = Date::today)
    return_events = []

    events.each do |event|
      list_ex_dates = []
      event.exception_dates.each do |ex|
        list_ex_dates << ex.date
      end
      next if list_ex_dates.include?(date)

      if date == event.start_at.to_date #&& date <= event.end_at.to_date
        return_events << event
      elsif event.start_at.to_date < date
        case event.frequence
        when "DAILY"
          if (date - event.start_at.to_date).to_i % event.interval == 0
            if !event.until_date.nil?
              return_events << event if date <= event.until_date.to_date
            elsif !event.count.nil?
              return_events << event if event.start_at.to_date + (event.count * event.interval).days > date # FIXME Repair count option
            else
              return_events << event
            end
          end
        when "WEEKLY"
          is_by_day = false
          is_by_day = event.by_day.include?(daynum_to_dayname(date.wday)) unless event.by_day.nil?

          if (date - event.start_at.to_date).to_i % (7 * event.interval) == 0 || is_by_day
            if !event.until_date.nil?
              return_events << event if date <= event.until_date.to_date
            elsif !event.count.nil?
              return_events << event if event.start_at.to_date + (event.count * event.interval).weeks > date # FIXME Repair count option
            else
              return_events << event
            end
          end
        when "MONTHLY"
          years_diff = date.year - event.start_at.year
          months_diff = date.month - event.start_at.month
          if months_diff < 0
            months_diff = 12 + months_diff
            years_diff -= 1
          end
          months_between =years_diff*12 + months_diff

          month_condition = false
          if event.by_month_day.nil? && event.by_day.nil?
            month_condition = true if event.start_at.day == date.day
          elsif !event.by_month_day.nil? && event.by_day.nil?
            month_condition = event.by_month_day.include?(date.day.to_s)
          elsif event.by_month_day.nil? && !event.by_day.nil?
            is_by_day = true
            if !event.by_day.nil?
              week_number = event.by_day.first[0...-2].to_i
              week_day = dayname_to_daynum(event.by_day.first[-2...event.by_day.first.size])
              if week_day == date.wday && week_number == -1
                month_condition = false unless date.day > (date.end_of_month.day - 7)
              elsif week_day == date.wday && !week_number.zero?
                month_condition = false unless (((date.day - 1) / 7) + 1) == week_number
              else
                month_condition = false
              end
            end
          end

          if months_between % event.interval == 0 && month_condition
            if !event.until_date.nil?
              return_events << event if date <= event.until_date.to_date
            elsif !event.count.nil?
              return_events << event if event.start_at.to_date + (event.count * event.interval).months > date # FIXME Repair count option
            else
              return_events << event
            end
          end
        when "YEARLY"
          year_condition = false
          if event.by_month.nil? && event.by_day.nil?
            year_condition = true if (event.start_at.day == date.day && event.start_at.month == date.month)
          elsif !event.by_month.nil?
            year_condition = event.by_month.include?(date.month.to_s)

            if !event.by_day.nil? && year_condition
              week_number = event.by_day.first[0...-2].to_i
              week_day = dayname_to_daynum(event.by_day.first[-2...event.by_day.first.size])
              if week_day == date.wday && week_number == -1
                year_condition = false unless date.day > (date.end_of_month.day - 7)
              elsif week_day == date.wday && !week_number.zero?
                year_condition = false unless (((date.day - 1) / 7) + 1) == week_number
              else
                year_condition = false
              end
            elsif event.start_at.day != date.day && year_condition
              year_condition = false
            end
          end

          if (date.year - event.start_at.year) % event.interval == 0 && year_condition
            if !event.until_date.nil?
              return_events << event if date <= event.until_date.to_date
            elsif !event.count.nil?
              return_events << event if event.start_at.to_date + (event.count * event.interval).year > date # FIXME Repair count option
            else
              return_events << event
            end
          end
        end # case
      end # if
    end # each

    return_events
  end

  def alarms_at_date(date = Date::today)
    return_alarms
    events.each do |event|
      event.alarms.each do |alarm|
        # TODO
      end
    end
  end

  # Convert the current calendar to the ics format
  def convert_to_ics
    cal = Icalendar::Calendar.new
    cal.properties["prodid"]          = "-//" + PRODUCT_CORP +
    "//" + PRODUCT_NAME +
    "//" + PRODUCT_LANG
    cal.properties["x-wr-timezone"]   = TIME_ZONE
    cal.properties["x-wr-calname"]    = title if title
    events.each do |event|
      cal.add_event(event.to_ical_event)
    end
    cal.to_ical
  end

  def self.to_ical_date(date)
    date.to_datetime
  end

  def self.param_tz
    {"TZID" => TIME_ZONE}
  end

  def self.to_ical_seconds(seconds)
    "PT" + seconds.to_s + "S"
  end

  protected
  def daynum_to_dayname(num)
    case num
    when 0
      return "SU"
    when 1
      return "MO"
    when 2
      return "TU"
    when 3
      return "WE"
    when 4
      return "TH"
    when 5
      return "FR"
    when 6
      return "SA"
    end
  end

  def dayname_to_daynum(name)
    case name
    when "SU"
      return 0
    when "MO"
      return 1
    when "TU"
      return 2
    when "WE"
      return 3
    when "TH"
      return 4
    when "FR"
      return 5
    when "SA"
      return 6
    end
  end
end
