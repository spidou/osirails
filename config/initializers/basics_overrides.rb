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
  
  # Method that return true if the array passed as argument contain the same elements (same type too) regardless their order
  #
  # [1,2,3].same_elements?([3,1,2]) == true
  # [2,3,4].same_elements?([2,3,4,5]) == false
  #
  def same_elements?(array)
    size == array.size && include_all?(array)
  end
  
  # [1,2,3].include_all?([1,2]) == true
  # [1,2,3].include_all?([1,6]) == false
  #
  def include_all?(array)
    (self & array).size == array.size
  end
  
  # [1,2,3].include_any?([1,2]) == true
  # [1,2,3].include_any?([1,6]) == true
  # [1,2,3].include_any?([5,6]) == false
  #
  def include_any?(array)
    (self & array).size >= 1
  end
  
  # return the average of the array values
  # 
  # [1,2,3].avg # => 2
  # [1,2].avg   # => 1.5
  # ["a","b"]   # => ERROR
  # [1,2,"3"]   # => ERROR
  def avg
    if self.any?
      @avg = self.sum / self.size.to_f
      @avg.to_i == @avg ? @avg.to_i : @avg
    else
      0
    end
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
    case self.strip # avoid spaces
      when "true", "1"
        return true
      when "false", "0"
        return false
      else
        return nil 
    end
  end
  
  # return if the string is a numeric value
  # 
  # "foo".numeric?  # false
  # "100".numeric?  # true
  # "4.8".numeric?  # true
  # "7bar".numeric? # false
  def numeric?
    return true if Float(self) rescue false
  end
  
  # return shortened string according to the fixed +limit+
  # followed by the +substitute_text+
  # 
  # "Hello World!".shorten(8)         # "Hello Wo"
  # "Hello World!".shorten(5, "...")  # "Hello..."
  def shorten(limit, substitute_text = "")
    raise TypeError, "wrong argument type #{limit.class.name} (expected Fixnum)" unless limit.is_a?(Fixnum)
    chars = self.mb_chars
    chars.length > limit ? (chars[0...limit] + substitute_text.to_s).to_s : self
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
    ActiveSupport::Deprecation.warn("humanize is now deprecated, please use localize instead. eg: l(date)", caller)
    I18n.l(self)
  end
end

class DateTime
  def humanize
    ActiveSupport::Deprecation.warn("humanize is now deprecated, please use localize instead. eg: l(date)", caller)
    I18n.l(self)
  end
end

module ActiveSupport
  class TimeWithZone
    def humanize
      ActiveSupport::Deprecation.warn("humanize is now deprecated, please use localize instead. eg: l(date)", caller)
      I18n.l(self.to_datetime)
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
      decimals = str.from(str.index(".") + 1).to(precision - 1).ljust(precision, "0")
      "#{integer}.#{decimals}"
    end
  end
  
  alias_method_chain :to_s, :precision
end

### little hack that permit to reverse sort_by like: ( source : http://groups.google.com/group/comp.lang.ruby/msg/c6646699efca9443?dmode=source )
#   Employee.all.sort_by {|n| [n.last_name]}     => Employee.all :order => 'last_name Asc'
#   Employee.all.sort_by {|n| [n.last_name.rev]} => Employee.all :order => 'last_name Desc'
# 
class Reverser
  attr_accessor :obj

  def initialize(obj)
    @obj = obj
  end
  
  def <=>(other)
    other.obj <=> self.obj
  end
end

class Object
  def rev
    Reverser.new(self)
  end
end

