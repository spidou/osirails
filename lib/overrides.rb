Date::MONTHNAMES = [nil] + %w( Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre )
Date::ABBR_MONTHNAMES = [nil] + %w( Jan Fév Mar Avr Mai Juin Juil Aoû Sep Oct Nov Déc )
Date::DAYNAMES = %w( Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi )
Date::ABBR_DAYNAMES = %w( Dim Lun Mar Mer Jeu Ven Sam )

class Time
 alias :strftime_nolocale :strftime
 
 # constants for schedules
 DAYS = {"Lundi"=>1,"Mardi"=>2,"Mercredi"=>3,"Jeudi"=>4,"Vendredi"=>5,"Samedi"=>6,"Dimanche"=>7}
 R_DAYS = {1=>"Lundi",2=>"Mardi",3=>"Mercredi",4=>"Jeudi",5=>"Vendredi",6=>"Samedi",7=>"Dimanche"}
 DEFAULT_DAYS_ARRAY = ["",{ 'day' => "Lundi" },{ 'day' => "Mardi"},{ 'day' => "Mercredi"},{ 'day' => "Jeudi"},{ 'day' => "Vendredi"},{ 'day' => "Samedi"},{ 'day' => "Dimanche"}]
 
 def strftime(format)
  format = format.dup
  format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
  format.gsub!(/%A/, Date::DAYNAMES[self.wday])
  format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
  format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
  self.strftime_nolocale(format)
 end
end

class Array

  # methods that return true if the array have only nil values
  def all_values_nil?
    var = true
    self.each do |f|
      var = false if !f.nil?
    end
    return var 
  end
  
end
