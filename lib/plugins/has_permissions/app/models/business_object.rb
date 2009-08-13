class BusinessObject < ActiveRecord::Base
  setup_has_permissions_model :association_options => { :name => :permissions }
  
  validates_uniqueness_of :name
  
  after_create :create_permissions_methods_associations
  
  def permissions_definitions
    name.constantize.permissions_definitions
  end
  
  private
    def create_permissions_methods_associations
      permissions_definitions[:permission_methods].each do |method|
        permissions.each do |bo_permission|
          BusinessObjectPermissionsPermissionMethod.create(:business_object_permission_id => bo_permission.id,
                                                           :permission_method_id => PermissionMethod.find_by_name(method.to_s).id)
        end
      end
    end
end
