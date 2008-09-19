SocietyActivitySector.module_eval do 
  has_and_belongs_to_many :order_types
end

Customer.module_eval do 
  has_many :orders
end

Establishment.module_eval do 
  has_many :orders
end