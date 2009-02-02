class Contact < ActiveRecord::Base
  include Permissible
  
  has_many :numbers, :as => :has_number
  belongs_to :contact_type
  # Declaration for has_many_polymorph association
  has_many :contacts_owners, :foreign_key => "contact_id", :class_name => "ContactsOwners"
  #TODO are those lines really useful? 'has_many :contacts_owners' is not necessary alone?
  has_many :thirds, :source => :has_contact, :through => :contacts_owners, :source_type => "Third", :class_name => "Third"
  has_many :establishments, :source => :has_contact, :through => :contacts_owners, :source_type => "Establishment", :class_name => "Establishment"
  has_many :employees, :source => :has_contact, :through => :contacts_owners, :source_type => "Employee", :class_name => "Employee"
  has_many :orders, :source => :has_contact, :through => :contacts_owners, :source_type => "Order", :class_name => "Order"
  #####
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_format_of :email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/ #,:message => "format adresse email incorrect"
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:first_name] = "Prénom :"
  @@form_labels[:last_name] = "Nom de famille :"
  @@form_labels[:email] = "Adresse e-mail :"
  @@form_labels[:job] = "Fonction :"
  @@form_labels[:contact_type] = "Type de contact :"
  
#  def self.new(contact = nil)
#    
#    unless contact.nil? or contact[:id].nil?
#      if contact[:id].blank?
#        contact.delete("id")
#        contact.delete("selected")
#        contact.delete("valid")
#        return super(contact)
#      else
#        return Contact.find(contact[:id])
#      end           
#    end
#    super(contact)
#  end

  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
  def fullname
    "#{first_name} #{last_name}"
  end
  
  def fullname_and_number
    number = ""
    
    self.numbers.each do |n|
      if n.visible?
        number = ", Tél: #{n.formated}"
      end
    end
    
    "#{fullname}#{number}"
  end
  
  def fullname_number_and_job
    job = ", #{self.job}" unless self.job.empty?
    
    "#{fullname_and_number}#{job}"
  end
  
  def fullname_number_job_and_contact_type
    "#{fullname_number_and_job}, Type: #{contact_type.name}"
  end
  
end