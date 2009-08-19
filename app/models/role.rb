class Role < ActiveRecord::Base

  # Relationships
  has_and_belongs_to_many :users
  
  has_many :permissions, :dependent => :destroy
  
  has_many :menu_permissions, :class_name => "Permission",
                              :include    => :menu,
                              :conditions => [ "has_permissions_type = ?", "Menu" ]
  
  has_many :business_object_permissions, :class_name => "Permission",
                                         :include    => :business_object,
                                         :conditions => [ "has_permissions_type = ?", "BusinessObject" ]
  
  has_many :document_type_permissions, :class_name => "Permission",
                                       :include    => :document_type,
                                       :conditions => [ "has_permissions_type = ?", "DocumentType" ]
  
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
  
  has_search_index :only_attributes => [:name, :description] if Object.const_defined?("HasSearchIndex")
                    
  private
    def create_role_permissions
      %W{ BusinessObject Menu DocumentType }.each do |klass|
        klass.constantize.all.each do |object|
          permission = Permission.create!(:role_id              => self.id,
                                          :has_permissions_id   => object.id,
                                          :has_permissions_type => klass)
          
          perm_klass = object.is_a?(BusinessObject) ? object.name.constantize : object.class
          perm_klass.all_permission_methods.each do |method|
            PermissionsPermissionMethod.create!(:permission_id        => permission.id,
                                                :permission_method_id => PermissionMethod.find_by_name(method.to_s).id)
          end
        end
      end
    end
end
