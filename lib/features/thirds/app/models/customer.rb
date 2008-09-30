class Customer < Third
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  acts_as_file
  
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  acts_as_file
  
  def activated_establishments
    establishment_array = []
    self.establishments.each {|establishment| establishment_array << establishment if establishment.activated}
    return establishment_array
  end
  
end