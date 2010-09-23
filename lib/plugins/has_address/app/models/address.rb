class Address < ActiveRecord::Base
  belongs_to :has_address, :polymorphic => true
  
  validates_presence_of :has_address_type, :has_address_key
  validates_presence_of :street_name, :country_name, :city_name
  
  validates_numericality_of :zip_code
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:street_name]   = "Adresse :"
  @@form_labels[:country_name]  = "Pays :"
  @@form_labels[:city_name]     = "Ville :"
  @@form_labels[:zip_code]      = "Code postal :"
  
  has_search_index :only_attributes => [ :street_name, :city_name, :country_name, :zip_code],
                   :additional_attributes => {:formatted => :string }
  
  def formatted
    @formatted ||= [street_name, zip_code, city_name, country_name].join(" ")
  end
end
