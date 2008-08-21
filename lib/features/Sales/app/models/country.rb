class Country < ActiveRecord::Base
  has_many :cities
  validates_uniqueness_of :name
end