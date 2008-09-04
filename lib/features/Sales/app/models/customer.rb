class Customer < Third
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  acts_as_file
end