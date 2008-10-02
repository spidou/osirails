require 'test_helper'
require File.dirname(__FILE__) + '/../admin_test'

require 'business_object_permissions_controller'

# re-raise errors caught by the controller.
class BusinessObjectPermissionsController; def rescue_action(e) raise e end; end

class BusinessObjectPermissionsControllerTest < ActionController::TestCase
  
  # assert_valid_markup :index, :edit, :but_first => :login_as_powerful_user
  
  def setup
    @controller = BusinessObjectPermissionsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
end
