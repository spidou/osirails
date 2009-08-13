module EstimateDuration

  # method to get leave duration in days(float), the period start is taken in account
  def total_estimate_duration(period_start = start_date, period_end = end_date)
    return 0 if period_start.nil? or period_end.nil?
    total = 0.0
    workable_days = ConfigurationManager.admin_society_identity_configuration_workable_days
    legal_holidays = ConfigurationManager.admin_society_identity_configuration_legal_holidays
    current = period_start
    (period_end - period_start + 1).to_i.times do
      total += 1 if workable_days.include?(current.wday.to_s) and !legal_holidays.include?("#{current.month}/#{current.day}")
      current = current.tomorrow 
    end
    total -= 0.5 if end_half and workable_days.include?(period_end.wday.to_s)
    total -= 0.5 if start_half and workable_days.include?(period_start.wday.to_s)  
    return total
  end
  
  # method that take in account retrieval value if there's one
  def estimate_duration
    #total_estimate_duration(period_start, period_end) - retrieval unless retrieval.nil?
    value = total_estimate_duration(start_date, end_date)
    value -= retrieval unless retrieval.nil?
    value
  end
  
end
