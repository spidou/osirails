class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :menus
  validates_uniqueness_of :name
end
