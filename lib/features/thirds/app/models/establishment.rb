class Establishment  < ActiveRecord::Base
  include Permissible
    
  has_one :address, :as => :has_address
  has_many  :contacts, :as => :has_contacts
  belongs_to :customer
  belongs_to :establishment_type
  validates_presence_of :name
  validates_presence_of :address
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact, :class_name => "ContactsOwners"
  has_many :contacts, :source => :contact, :foreign_key => "contact_id", :through => :contacts_owners, :class_name => "Contact"
  
  def self.new(establishment = nil)
    unless establishment.nil? or establishment[:valid].nil?
      address = establishment.delete("address")
      establishment.delete("valid")
      establishment_object =Establishment.new(establishment)
      ## unless city_name and city_zip_code are disabled
      establishment_object.address = (address_object = Address.new(:address1 => address[:address1], :address2 => address[:address2], 
          :country_name => address[:country][:name], :city_name => (address[:city][:name] unless address[:city].nil?), 
          :zip_code => (address[:city][:zip_code] unless address[:city].nil?)))
      return establishment_object
    else     
      super(establishment)
    end
  end
  
  ## Return full address's establishment
  def full_addresss
    [self.address.address1,(self.address.address2 unless self.address.address2.blank?), self.address.zip_code, self.address.city_name, self.address.country_name].join(" ")
  end
end