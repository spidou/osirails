class Country < ActiveRecord::Base
  has_many :cities
  has_one :indicative
  validates_uniqueness_of :name
end
