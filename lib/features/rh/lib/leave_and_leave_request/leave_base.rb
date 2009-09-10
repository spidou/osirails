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
  
  def start_date_and_end_date
    start_date and end_date
  end
  
  def start_datetime
    start_half ? start_date.to_datetime + (12.hours + 1.minute) : start_date.to_datetime
  end
  
  def end_datetime
    end_half ? end_date.to_datetime + 12.hours : end_date.to_datetime + (23.hours + 59.minutes)
  end
  
  def two_half_for_same_date?
    start_half and end_half and start_date == end_date
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
    if start_date_and_end_date and employee
      collection.select{ |l| l.start_datetime.between?(self.start_datetime, self.end_datetime) or
                             l.end_datetime.between?(self.start_datetime, self.end_datetime) }
    else
      return []
    end
  end
  
  private
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
