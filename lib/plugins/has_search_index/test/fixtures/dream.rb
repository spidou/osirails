class Dream < ActiveRecord::Base
  has_many :people_dreams
  has_many :people, :through => :people_dreams
end
