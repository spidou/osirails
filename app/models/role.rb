class Role < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :users
  has_many :menu_permissions
  has_many :business_object_permissions
  
  # Validations
  validates_uniqueness_of :name
  validates_presence_of :name
  
  # Callbacks
  after_create :create_role_permissions
  after_destroy :destroy_role_permissions

  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom du r&ocirc;le :"
  @@form_labels[:description] = "Description du r&ocirc;le :"
  @@form_labels[:user] = "Membres :"
  
  def create_role_permissions
    all_business_objects = BusinessObjectPermission.find(:all, :group => 'has_permission_type')
    all_business_objects.each do |bo|
      BusinessObjectPermission.create(:role_id => self.id, :has_permission_type => bo.has_permission_type)
    end
    
    all_menus = Menu.find(:all)
    all_menus.each do |m|
      MenuPermission.create(:role_id => self.id, :menu_id => m.id)
    end
    
    all_document_types = DocumentPermission.find(:all, :group => 'document_owner')
    all_document_types.each do |d|
      DocumentPermission.create(:role_id => self.id, :document_owner => d.document_owner)
    end
    
    # permissions are configurable only for calendar which have no owner
    all_calendars = Calendar.find_all_by_user_id(nil)
    all_calendars.each do |c|
      CalendarPermission.create(:role_id => self.id, :calendar_id => c.id)
    end
  end
  
  def destroy_role_permissions
    BusinessObjectPermission.destroy_all(:role_id => self.id)
    MenuPermission.destroy_all(:role_id => self.id)
    DocumentPermission.destroy_all(:role_id => self.id)
    CalendarPermission.destroy_all(:role_id => self.id)
  end
end
