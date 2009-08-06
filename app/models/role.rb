class Role < ActiveRecord::Base

  # Relationships
  has_and_belongs_to_many :users
  has_many :menu_permissions,             :include => :menu,            :dependent => :destroy
  has_many :business_object_permissions,  :include => :business_object, :dependent => :destroy
  has_many :document_type_permissions,    :include => :document_type,   :dependent => :destroy
  #has_many :calendar_permissions,         :include => :calendar,        :dependent => :destroy, :conditions => [ "calendars.user_id = ?",  nil ]
  
  # Validations
  validates_uniqueness_of :name
  validates_presence_of :name
  
  # Callbacks
  after_create :create_role_permissions

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom du r&ocirc;le :"
  @@form_labels[:description] = "Description du r&ocirc;le :"
  @@form_labels[:user] = "Membres :"
  
  has_search_index :only_attributes => ["name", "description"] if Object.const_defined?("HasSearchIndex")
                    
  private
    def create_role_permissions
      business_objects = BusinessObject.find(:all).each do |bo|
        BusinessObjectPermission.create(:role_id => self.id, :business_object_id => bo.id)
      end
      
      Menu.find(:all).each do |menu|
        MenuPermission.create(:role_id => self.id, :menu_id => menu.id)
      end
      
      DocumentType.find(:all).each do |document_type|
        DocumentTypePermission.create(:role_id => self.id, :document_type_id => document_type.id)
      end
      
      ## permissions are configurable only for calendar which have no owner
      #Calendar.find_all_by_user_id(nil).each do |calendar|
      #  CalendarPermission.create(:role_id => self.id, :calendar_id => calendar.id)
      #end
    end
end
