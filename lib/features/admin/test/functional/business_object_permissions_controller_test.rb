require File.dirname(__FILE__) + '/../admin_test'

require 'business_object_permissions_controller'

class BusinessObjectPermissionsController; def rescue_action(e) raise e end; end

class BusinessObjectPermissionsControllerTest < ActionController::TestCase
  def setup
    init_menus_and_permissions
    @controller = BusinessObjectPermissionsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    logged_as(:admin_user)
  end

  def test_index
    get :index

    assert_equal BusinessObject.all, assigns(:business_objects),
      "The index of BusinessObjectController should return an array of BusinessObject"
  end

  def test_edit
    business_object = BusinessObject.first
    get :edit, :id => business_object.id

    assert business_object, assigns(:business_object)
    assert business_object.permissions, assigns(:business_object_permissions)
  end

  def test_update_with_some_permissions
    business_object = BusinessObject.first
    permission = business_object.permissions.first
    
    put :update, :id => business_object.id, :permissions => { permission.id => { permission.permission_methods.first.name => true } }

    assert_not_nil flash[:notice]
    assert_redirected_to :controller => 'business_object_permissions', :action => 'edit', :id => business_object.id
  end
end
