class Address < ActiveRecord::Base

  belongs_to :has_address, :polymorphic => true
  has_one :city
  
  validates_presence_of :address1
  validates_presence_of :country_name
  validates_presence_of :city_name
  validates_presence_of :zip_code
  validates_numericality_of :zip_code
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:address1] = "Adresse :"
  @@form_labels[:country_name] = "Pays :"
  @@form_labels[:city_name] = "Ville :"
  @@form_labels[:zip_code] = "Code postal :"
  
  # Search Plugin
  has_search_index :only_attributes => ["zip_code","city_name","country_name"]
  
  def address1and2
    address = address1
    address << " - " + address2 unless address2.blank?
    address
  end
  
  def formatted
    [address1, (address2 unless address2.blank?), zip_code, city_name, country_name].join(" ")
  end
end
