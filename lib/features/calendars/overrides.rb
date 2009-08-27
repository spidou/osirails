require_dependency 'user'
require_dependency 'role'

class Role
  has_many :document_type_permissions, :class_name => "Permission",
                                       :include    => :calendar,
                                       :conditions => [ "has_permissions_type = ? and calendars.user_id = ?", "Calendar", nil ]
  
  after_create :create_calendar_permissions
  
  private
    def create_calendar_permissions
      # permissions are configurable only for calendar which have no owner
      Calendar.find_all_by_user_id(nil).each do |calendar|
        permission = Permission.create(:role_id => self.id, :has_permissions_id => calendar.id, :has_permissions_type => "Calendar")
        
        Calendar.all_permission_methods.each do |method|
          PermissionsPermissionMethod.create!(:permission_id        => permission.id,
                                              :permission_method_id => PermissionMethod.find_by_name(method.to_s).id)
        end
      end
    end
end

class User 
  has_one :calendar
end
