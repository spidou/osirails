module EventsHelper
  def event_freq (event)
    return "Personnaliser" if event.is_custom_frequence?
    case event.frequence
    when "DAILY"
      return "chaque jour"
    when "WEEKLY"
      return "chaque semaine"
    when "MONTHLY"
      return "chaque mois"
    when "YEARLY"
      return "chaque année"
    end
  end

  def event_freq_end (event)
    if !event.until_date.nil?
      return "Le " + event.until_date.to_date.to_s
    elsif !event.count.nil?
      return "Après " + event.count.to_s + " fois"
    elsif !event.frequence.nil?
      return "Jamais"
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

  def days_sentence(event)
    return if event.by_day.nil?
    days_tab = []
    event.by_day.each do |day|
      days_tab << $day_fr[dayname_to_daynum(day)]
    end
    days_concat = "le " + days_tab.join(', ')
    last_comma_position = days_concat.rindex(',')
    days_concat[last_comma_position] = ", et" unless last_comma_position.nil?
    days_concat
  end
  
  def month_days_sentence(event)
    return if event.by_month_day.nil?
    month_days_tab = []
    event.by_month_day.each do |day|
      month_days_tab << day.to_s + 'e'
    end
    month_days_concat = ", chaque " + month_days_tab.join(', ')
    last_comma_position = month_days_concat.rindex(',')
    month_days_concat[last_comma_position] = ", et" unless last_comma_position.nil?
    month_days_concat
  end
  
  def day_sentence(event)
    return if event.by_day.nil?
    case event.by_day.first[0...-2].to_i
    when 1
      number = "premier"
    when 2
      number = "deuxième"
    when 3
      number = "troixième"
    when 4
      number = "quatrième"
    when -1
      number = "dernier"
    end
    day_name = $day_fr[dayname_to_daynum(event.by_day.first[-2...event.by_day.first.size])]
    ", le " + number + " " + day_name
  end
  
  def month_sentence(event)
    return if event.by_month.nil?
    months_tab = []
    event.by_month.each do |month|
      months_tab << $month_fr[month.to_i]
    end
    month_concat = " en " + months_tab.join(', ')
    last_comma_position = month_concat.rindex(',')
    month_concat[last_comma_position] = ", et" unless last_comma_position.nil?
    month_concat
  end
  
  def alarm_sentence(event)
    alarm = event.alarms.first
    case alarm.action.upcase
    when "DISPLAY"
      action = "afficher un message"
    when "EMAIL"
      action = "envoyer un courrier électronique à #{alarm.email_to}"      
    end
    action + " #{alarm.do_alarm_before} minutes avant"
  end
end
