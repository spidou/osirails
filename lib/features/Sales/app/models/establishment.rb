class Establishment  < ActiveRecord::Base
  has_one :address, :as => :has_address
  has_many  :contacts
  belongs_to :third
end