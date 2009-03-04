silence_warnings do
  Date::MONTHNAMES = [nil] + %w( Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre )
  Date::ABBR_MONTHNAMES = [nil] + %w( Jan Fév Mar Avr Mai Juin Juil Aoû Sep Oct Nov Déc )
  Date::DAYNAMES = %w( Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi )
  Date::ABBR_DAYNAMES = %w( Dim Lun Mar Mer Jeu Ven Sam )
end

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

  def fusion(arg)
    array = Array.new + arg
    return nil unless array.class == Array
    self.each do |elmnt|
      array << elmnt unless array.include?(elmnt)
    end
    return array
  end

end

class String

  # Method to return formated string without accents
  def strip_accents
    formated = self
    with_accent = "áéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙäëïöüÿÄËÏÖÜâêîôûÂÊÎÔÛåÅøØßçÇãñõÃÑÕ".split("")
    without_accent = "aeiouyAEIOUYaeiouAEIOUaeiouyAEIOUaeiouAEIOUaAoOscCanoANO".split("")
    self.split("").each do |letter|
      with_accent.each_with_index do |accentuate,index|
        formated = formated.gsub(letter,without_accent[index]) if letter == accentuate
      end
    end
    return formated
  end

  # method to view if a word is or not is plural
  def plural?
    self.singularize == self ? false : true
  end
end

class Hash
  def fusion(hash)
    return_hash = Hash.new.merge(hash)
    self.each do |key, value|
      if hash[key].nil?
        return_hash[key] = value
      elsif self[key].class == Hash && hash[key].class == Hash
        return_hash[key] = self[key].fusion(hash[key])
      else
        raise TypeError, "can't fusion #{self[key].class} with #{hash[key].class}"
      end
    end
    return_hash
  end
end

module ActiveRecord
  class Errors
    @@default_error_messages.update( {
      :inclusion => "n'est pas inclut dans la liste",
      :exclusion => "est réservé",
      :invalid => "est invalide",
      :confirmation => "ne correspond pas à la confirmation",
      :accepted => "doit être accepté",
      :empty => "ne peut pas être vide",
      :blank => "est requis",
      :too_long => "est trop long (%d caractères maximum)",
      :too_short => "est trop court(%d caractères minimum)",
      :wrong_length => "n'est pas de la bonne longueur (devrait être de %d caractères)",
      :taken => "est déjà  prit",
      :not_a_number => "n'est pas un nombre",
    })
  end
end

module ActiveSupport
  class TimeWithZone
    def to_humanized_date
      self.strftime("%d %B %Y")
    end

    def to_humanized_datetime
      self.strftime("%d %B %Y à %I:%M")
    end
  end
end
