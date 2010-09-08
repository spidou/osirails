begin
  BusinessObject.all.select{ |bo| bo.name.constantize rescue false }.each do |bo|
    Role.all.each do |role|
      permission = Permission.find_or_create_by_role_id_and_has_permissions_id_and_has_permissions_type(role.id, bo.id, "BusinessObject")
      
      bo.name.constantize.class_permission_methods.each do |method|
        PermissionsPermissionMethod.find_or_create_by_permission_id_and_permission_method_id(permission.id, PermissionMethod.find_or_create_by_name(method.to_s).id)
      end
    end
  end
rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError, Exception => e
  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  RAKE_TASK ? puts(error) : raise(e)
end
