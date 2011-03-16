class PaymentMethod < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  journalize :identifier_method => :name
end
