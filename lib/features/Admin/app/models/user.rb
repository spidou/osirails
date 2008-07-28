class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  validates_uniqueness_of :username
  validates_confirmation_of :password
end
