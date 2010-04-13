class Contact < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_numbers
  
  belongs_to :contact_type
  
  has_many :contacts_owners, :foreign_key => "contact_id", :dependent => :destroy
  has_many :numbers, :as => :has_number
  
  validates_presence_of   :first_name, :last_name, :contact_type, :gender
  validates_format_of     :email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/, :message => "L'adresse e-mail est incorrecte"
  validates_inclusion_of  :gender, :in => %w( M F )
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  cattr_accessor :contacts_owners_models
  @@contacts_owners_models = []
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:gender]        = "Genre :"
  @@form_labels[:first_name]    = "Prénom :"
  @@form_labels[:last_name]     = "Nom :"
  @@form_labels[:email]         = "Adresse e-mail :"
  @@form_labels[:job]           = "Fonction :"
  @@form_labels[:contact_type]  = "Type de contact :"
  @@form_labels[:avatar]        = "Photo :"
  
  has_attached_file :avatar, 
                    :styles => { :thumb => "75x75#" },
                    :default_style => :thumb,
                    :path => ":rails_root/assets/contacts/avatars/:id/:style.:extension",
                    :url => "/contacts/:id/avatar",
                    :default_url => ":current_theme_path/images/avatars/:gender.png"
  
  has_search_index  :only_attributes => [ :first_name, :last_name, :email ]
  
  before_save :case_management

  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
  def fullname
    "#{first_name} #{last_name}"
  end
  
  private
    def case_management
      self.first_name = self.first_name.chars.capitalize
      self.last_name = self.last_name.chars.upcase
    end
  
end
