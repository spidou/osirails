class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
  has_one :city
  
  validates_presence_of :address1
  validates_presence_of :country_name
  validates_presence_of :city_name
  validates_presence_of :zip_code
  validates_numericality_of :zip_code
  
  def formatted
    [address1, (address2 unless address2.blank?), zip_code, city_name, country_name].join(" ")
  end
end