class BusinessObject < ActiveRecord::Base
  setup_has_permissions_model
  
  validates_uniqueness_of :name
  
  after_create :create_permission_methods_associations
  
  def all_permission_methods
    name.constantize.all_permission_methods
  end
  
  def title
    name.titleize
  end
  
  private
    def create_permission_methods_associations
      all_permission_methods.each do |method|
        permissions.each do |permission|
          PermissionsPermissionMethod.create(:permission_id => permission.id,
                                             :permission_method_id => PermissionMethod.find_by_name(method.to_s).id)
        end
      end
    end
end
