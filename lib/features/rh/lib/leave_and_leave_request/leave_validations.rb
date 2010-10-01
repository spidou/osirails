module LeaveValidations
  
  private
    def validates_dates_consistency
      if start_date > end_date
        errors.add(:start_date, "est postérieure à la date de fin")
        errors.add(:end_date, "est antérieure à la date de début")
      end
      
      if two_half_for_same_date?
        errors.add_to_base("Les demi-journées ne peut être sélectionnés ensemble pour la même date")
        errors.add(:start_half)
        errors.add(:end_half)
      end
    end
    
    def check_unique_dates(collection)
      return if collection.empty?
      
      collection = collection.group_by{ |x| x.class.class_name.titleize.downcase }
      
      error_message = "Les dates demandées ne sont pas valides<br/>"
      for group, items in collection
        error_message += "<br/>Vous avez déjà posé #{items.size} "
        error_message += items.many? ? "#{group.pluralize} pour les dates/périodes suivantes :<br/>" : "#{group} pour la date/période suivante :<br/>"
        for item in items.sort_by(&:start_date)
          error_message += "- " + item.formatted + "<br/>"
        end
      end
      
      errors.add_to_base(error_message)
      errors.add(:start_date)
      errors.add(:end_date)
    end
    
end
