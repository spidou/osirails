class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
  
  validates_presence_of :has_address_type, :has_address_key
  validates_presence_of :street_name, :country_name, :city_name, :zip_code
  
  journalize :attributes        => [ :street_name, :zip_code, :city_name, :region_name, :country_name ],
             :identifier_method => :formatted
  
  has_search_index :only_attributes       => [ :street_name, :zip_code, :city_name, :region_name, :country_name ],
                   :additional_attributes => { :formatted => :string, :zip_code_and_city_name => :string }
  
  def formatted
    @formatted ||= [street_name, zip_code, city_name, region_name, country_name].compact.join(" ")
  end
  
  def zip_code_and_city_name
    @zip_code_and_city_name ||= [zip_code, city_name].compact.join(" ")
  end
end
