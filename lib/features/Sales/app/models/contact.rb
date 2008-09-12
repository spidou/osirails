class Contact < ActiveRecord::Base
  include Permissible
  
  has_many :numbers
  validates_presence_of :first_name
  validates_presence_of :last_name
  belongs_to :contact_type
  
  # Declaration for has_many_polymorph association
  has_many :contacts_owners, :foreign_key => "contact_id", :class_name => "ContactsOwners"
  has_many :thirds, :source => :has_contact, :through => :contacts_owners, :source_type => "Third", :class_name => "Third"
  has_many :establishments, :source => :has_contact, :through => :contacts_owners, :source_type => "Establishment", :class_name => "Establishment"
  has_many :employees, :source => :has_contact, :through => :contacts_owners, :source_type => "Employee", :class_name => "Employee"


  def self.new(contact = nil)
    
    unless contact.nil? or contact[:id].nil?
      if contact[:id].blank?
        contact.delete("id")
        contact.delete("selected")
        contact.delete("valid")
        contact.delete("number")       
        return super(contact)
      else
        return Contact.find(contact[:id])
      end           
    end
    super(contact)
  end
  
end