class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
  
  validates_presence_of :has_address_type, :has_address_key
  validates_presence_of :street_name, :country_name, :city_name
  
  validates_numericality_of :zip_code
  
  has_search_index :only_attributes => [ :street_name, :city_name, :country_name, :zip_code ]
  
  def formatted
    @formatted ||= [street_name, zip_code, city_name, country_name].join(" ")
  end
end
