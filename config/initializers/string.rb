class String
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
end
