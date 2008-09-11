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


  def self.new(contacts = nil)
    unless contacts.nil? or contacts[:number].nil?
      contact_objects = []
      contacts[:number][:value].to_i.times do |i|
          unless contacts["#{i+1}"][:valid] == 'false'
            if contacts["#{i+1}"][:id].blank?
              contacts["#{i+1}"].delete("id")
              contacts["#{i+1}"].delete("selected")
              contacts["#{i+1}"].delete("valid")
              contacts.delete("number")       
              contact_objects[i] = super(contacts["#{i+1}"])
            else
              contact_objects[i] = Contact.find(contacts["#{i+1}"][:id])
            end                 
          end
        end
        return contact_objects
    else
      super(contacts)
    end
  end
  
end