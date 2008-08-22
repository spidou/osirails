Date::MONTHNAMES = [nil] + %w( Janvier Février Mars Avril Mai Juin Juillet Août Séptembre Octobre Novembre Décembre )
Date::ABBR_MONTHNAMES = [nil] + %w( Jan Fév Mar Avr Mai Juin Juil Aoû Sép Oct Nov Déc )
Date::DAYNAMES = %w( Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi )
Date::ABBR_DAYNAMES = %w( Dim Lun Mar Mer Jeu Ven Sam )

class Time
 alias :strftime_nolocale :strftime
 
 def strftime(format)
  format = format.dup
  format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
  format.gsub!(/%A/, Date::DAYNAMES[self.wday])
  format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
  format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
  self.strftime_nolocale(format)
 end
end