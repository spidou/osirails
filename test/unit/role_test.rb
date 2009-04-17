require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles, :users
  
  def setup
    @role_admin = roles(:admin)
    @role_guest = roles(:guest)
  end
  
  def test_create
    role = nil
    assert_difference 'Role.count', +1, "A Role should be created" do
      role = Role.create(:name => 'test_role', :description => 'test')
    end
    assert_equal BusinessObjectPermission.find_all_by_role_id(role.id).size,
      BusinessObject.count,
      "Some BusinessObjectPermission should be created"
    assert_equal MenuPermission.find_all_by_role_id(role.id).size,
      Menu.count,
      "Some MenuPermission should be created"
    assert_equal DocumentTypePermission.find_all_by_role_id(role.id).size,
      DocumentType.count,
      "Some DocumentTypePermission should be created"
    assert_equal CalendarPermission.find_all_by_role_id(role.id).size,
      Calendar.count,
      "Some CalendarPermission should be created"
  end
  
  def test_read
    assert_nothing_raised "A Role should be read" do
      Role.find_by_name(@role_admin.name)
    end
  end
  
  def test_update
    assert @role_admin.update_attributes(:name => 'new_name'), "A Role should be updated"
  end
  
  def test_delete
    role_id = @role_admin.id
    assert_difference 'Role.count', -1 do
      @role_admin.destroy
    end
    assert_equal [], BusinessObjectPermission.find_all_by_role_id(role_id), "Some BusinessObjectPermission should be destroyed"
    assert_equal [], MenuPermission.find_all_by_role_id(role_id), "Some MenuPermission should be destroyed"
    assert_equal [], DocumentTypePermission.find_all_by_role_id(role_id), "Some DocumentTypePermission should be destroyed"
    assert_equal [], CalendarPermission.find_all_by_role_id(role_id), "Some CalendarPermission should be destroyed"
  end
  
  def test_presence_of_name
    assert_no_difference 'Role.count' do
       role = Role.create(:name => '')
       assert_not_nil role.errors.on(:name), "A Role should not have a blank name"
     end
  end
  
  def test_uniqness_of_name
    assert_no_difference 'Role.count' do
       role = Role.create(:name => @role_admin.name)
       assert_not_nil role.errors.on(:name), "A Role should have an uniq name"
     end
  end
  
  def test_role_has_many_users
    @role_admin.users = [User.first, User.last]
    @role_admin.save
    assert_equal @role_admin.users, [User.first, User.last], "Some Users should be belongs to a Role"
  end
  
  def test_user_has_many_roles
    User.first.roles = [@role_admin, @role_guest]
    assert_equal @role_admin.users, @role_guest.users, "This User should have two roles"
  end
end