class Date
  
  def last_week
    monday - 1.week
  end
  
end

class Time
  #alias :strftime_nolocale :strftime

  # constants for schedules
  DAYS = {"Lundi"=>1,"Mardi"=>2,"Mercredi"=>3,"Jeudi"=>4,"Vendredi"=>5,"Samedi"=>6,"Dimanche"=>7}
  R_DAYS = {1=>"Lundi",2=>"Mardi",3=>"Mercredi",4=>"Jeudi",5=>"Vendredi",6=>"Samedi",7=>"Dimanche"}
  DEFAULT_DAYS_ARRAY = ["",{ 'day' => "Lundi" },{ 'day' => "Mardi"},{ 'day' => "Mercredi"},{ 'day' => "Jeudi"},{ 'day' => "Vendredi"},{ 'day' => "Samedi"},{ 'day' => "Dimanche"}]

  #def strftime(format)
  # format = format.dup
  # format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
  # format.gsub!(/%A/, Date::DAYNAMES[self.wday])
  # format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
  # format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
  # self.strftime_nolocale(format)
  #end
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
  
  # Method to truncate the begining of the current string according to the param
  def rchomp(separator = nil)
    mb_chars.reverse.chomp(separator.mb_chars.reverse).reverse.to_s
  end
  
  # method to view if a word is or not is plural #FIXME we may base on inflector class method to view if a word is or not plural
  def plural?
    return false if self.last == "s" and self.pluralize != self
    return true if self.last == "s" and self.pluralize == self
    return true if self.last != "s" and self.singularize != self
    return false if self.last != "s" and self.singularize == self
  end
  
  # return if the string is between the first and the second argument (without taking case into account)
  #
  def between(first, second)
    raise TypeError, "Both parameters must be #{self.class}. #{first}:#{first.class}, #{second}:#{second.class}" unless first.class.equal?(self.class) and second.class.equal?(self.class)
    self.downcase >= first.downcase and self.downcase <= second.downcase
  end

  # return if the string is between the first and the second argument (taking case into account)
  #
  def between_exact(first, second)
    raise TypeError, "Both parameters must be #{self.class}. #{first}:#{first.class}, #{second}:#{second.class}" unless first.class.equal?(self.class) and second.class.equal?(self.class)
    self >= first and self <= second
  end
  
  # return the boolean value according to the string
  #
  def to_b
    case self.strip             # avoid spaces
      when "true", "1"
        return true
      else
        return false 
    end 
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

class Date
  def humanize
    I18n.l(self, :format => :long)
  end
end

class DateTime
  def humanize
    I18n.l(self, :format => :short)
  end
end

module ActiveSupport
  class TimeWithZone
    def humanize
      self.to_datetime.humanize
    end
  end
end

class Numeric
  def round_to(precision = 0)
    if self.kind_of?(Float)
      (self * (10 ** precision)).round / (10 ** precision).to_f
    else
      self
    end
  end
end

class Float
  def to_s_with_precision(precision = nil)
    if precision.nil?
      self.to_s_without_precision
    elsif precision.instance_of?(Fixnum)
      str = self.to_s_without_precision
      integer = str.to(str.index(".") - 1)
      decimals = str.from(str.index(".") + 1).ljust(precision, "0")
      "#{integer}.#{decimals}"
    end
  end
  
  alias_method_chain :to_s, :precision
end
