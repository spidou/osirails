class City < ActiveRecord::Base
  belongs_to :country
  belongs_to :address
  
  validates_presence_of :name
  validates_presence_of :zip_code
  validates_presence_of :country_id
end