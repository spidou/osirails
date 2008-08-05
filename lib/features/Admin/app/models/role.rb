class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :menu_permissions
  has_many :business_object_permissions
  validates_uniqueness_of :name
  validates_presence_of :name
end
