class Wish < ActiveRecord::Base
  has_many :people_wishes
  has_many :people, :through => :people_whises
end
