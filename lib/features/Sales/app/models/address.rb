class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
  has_one :city
  validates_presence_of :address1
end