class Establishment  < ActiveRecord::Base
  has_one :address, :as => :has_address
  has_many  :contacts
  belongs_to :customer
  belongs_to :establishment_type
  validates_presence_of :name
end