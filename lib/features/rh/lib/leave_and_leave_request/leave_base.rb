module LeaveBase
  
  # method to get leave duration in days(float), the period start is taken in account
  def total_estimate_duration
    return 0 unless start_date and end_date
    total = 0.0
    workable_days = ConfigurationManager.admin_society_identity_configuration_workable_days
    legal_holidays = ConfigurationManager.admin_society_identity_configuration_legal_holidays
    current = start_date
    (end_date - start_date + 1).to_i.times do
      total += 1 if workable_days.include?(current.wday.to_s) and !legal_holidays.include?("#{current.month}/#{current.day}")
      current = current.tomorrow 
    end
    total -= 0.5 if end_half and workable_days.include?(end_date.wday.to_s)
    total -= 0.5 if start_half and workable_days.include?(start_date.wday.to_s)  
    return total
  end
  
  def calendar_duration
    return 0 unless start_date and end_date and start_date <= end_date
    total = (end_date - start_date).to_i + 1
    total -= 0.5 if end_half
    total -= 0.5 if start_half
    total
  end
  
  def start_datetime
    start_date.to_datetime + (start_half ? 12 : 0 ).hours
  end
  
  def end_datetime
    end_date.to_datetime + (end_half ? 12 : 24).hours
  end
  
  def formatted
    return "" unless start_date and end_date and !two_half_for_same_date?
    if start_date == end_date
      "Le " + start_date.strftime("%A %d %B %Y") + formatted_start_or_end_half
    else
      "Du " + start_date.strftime("%A %d %B %Y") + formatted_start_half + " au " + end_date.strftime("%A %d %B %Y") + formatted_end_half
    end
  end
  
  def conflicting_leaves(collection)
    return [] unless start_date_and_end_date and employee
    collection.select{ |l| start_datetime == l.start_datetime or  end_datetime == l.end_datetime or
                           (start_datetime < l.start_datetime and end_datetime > l.start_datetime) or
                           (start_datetime < l.end_datetime   and end_datetime > l.end_datetime) or
                           (start_datetime > l.start_datetime and end_datetime < l.end_datetime) or
                           (start_datetime < l.start_datetime and end_datetime > l.end_datetime) }
  end
  
  def future_leaves
    return [] unless start_date and employee
    employee.leaves.reject{ |n| n.id == id or n.end_date < start_date }
  end
  
  private
    
    def start_date_and_end_date
      start_date and end_date
    end
    
    def two_half_for_same_date?
      start_half and end_half and start_date == end_date
    end
    
    def formatted_start_half
      start_half ? " (après-midi)" : ""
    end
    
    def formatted_end_half
      end_half ? " (matinée)" : ""
    end
    
    def formatted_start_or_end_half
      formatted_end_half + formatted_start_half
    end
    
end
