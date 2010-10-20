class Parcel < ActiveRecord::Base
  has_reference :prefix => :purchases
  
  belongs_to :purchase_delivery

  validates_presence_of :reference
end
