require 'lib/seed_helper'

User.create_missing_calendars # for admin

Calendar.all.each do |object|
  object.permissions.each do |permission|
    permission.permissions_permission_methods.each do |object_permission|
      object_permission.update_attribute(:active, true)
    end
  end
end

set_default_permissions
