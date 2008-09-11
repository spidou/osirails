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
  
  def self.new(establishments = nil)
    unless establishments.nil? or establishments[:number].nil?
      address_objects = []
      establishment_objects = []
      establishments[:number][:value].to_i.times do |i|
        unless establishments["#{i+1}"][:valid] == 'false'
          address_objects[i] = establishments["#{i+1}"].delete("address")
          establishments["#{i+1}"].delete("valid")
          establishment_objects[i] =Establishment.new(establishments["#{i+1}"])
            
          ## If city_name and city_zip_code are disabled
          unless address_objects[i][:city].nil?
            establishment_objects[i].address = (address_objects[i] = Address.new(:address1 => address_objects[i][:address1], :address2 => address_objects[i][:address2], 
                :country_name => address_objects[i][:country][:name], :city_name => address_objects[i][:city][:name], :zip_code => address_objects[i][:city][:zip_code]))
          end
        end
      end
      return establishment_objects
    else     
      super(establishments)
    end
  end
end