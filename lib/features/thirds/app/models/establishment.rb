class Establishment  < ActiveRecord::Base
  has_permissions :as_business_object  

  # Relationships
  has_one :address, :as => :has_address
  
  belongs_to :customer
  belongs_to :establishment_type
  
  has_many  :contacts, :as => :has_contacts
  has_many :contacts_owners, :as => :has_contact
  has_many :contacts, :source => :contact, :through => :contacts_owners
  
  validates_presence_of :name
  validates_associated :address
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  after_update :save_address
  
  # Search Plugin
  has_search_index :only_attributes => ["name","activated"],
                   :only_relationships => [:contacts,:address]
                    
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom de l'enseigne :"
  @@form_labels[:establishment_type] = "Type d'établissement :"
  
#  def self.new(establishment = nil)
#    unless establishment.nil? or establishment[:valid].nil?
#      address = establishment.delete("address")
#      establishment.delete("valid")
#      establishment_object =Establishment.new(establishment)
#      ## unless city_name and city_zip_code are disabled
#      establishment_object.address = (address_object = Address.new(:address1 => address[:address1], :address2 => address[:address2], 
#          :country_name => address[:country][:name], :city_name => (address[:city][:name] unless address[:city].nil?), 
#          :zip_code => (address[:city][:zip_code] unless address[:city].nil?)))
#      return establishment_object
#    else     
#      super(establishment)
#    end
#  end
  
  ## Return full address's establishment
  def full_address
    address.formatted
  end
  
  def name_and_full_address
    "#{self.name} (#{self.full_address})"
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end

  # this method permit to save the address of the establishment when it is passed with the establishment form
  def address_attributes=(address_attributes)
    if address_attributes[:id].blank?
      self.address = build_address(address_attributes)
    else
      self.address.attributes = address_attributes
    end
  end
  
  def save_address
     address.save
  end
end
