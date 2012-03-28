class String
  # return if the string is a numeric value
  # 
  # "foo".numeric?  # false
  # "100".numeric?  # true
  # "4.8".numeric?  # true
  # "7bar".numeric? # false
  def numeric?
    return true if Float(self) rescue false
  end
end
