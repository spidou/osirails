def event_freq (event)
  case event.frequence.upcase
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
    return "Le " + event.until
  elsif !event.count.nil?
    return "Après " + event.count.to_s + " fois"
  elsif !event.frequence.nil?
    return "Jamais"
  end
end