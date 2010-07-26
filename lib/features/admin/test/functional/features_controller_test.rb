require File.dirname(__FILE__) + '/../admin_test'

require 'features_controller'

class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < ActionController::TestCase
  fixtures :features

  def setup
    init_menus_and_permissions
    @controller = FeaturesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    logged_as(:admin_user)
  end

  #def test_index
  #  get :index
  #  assert_equal Feature.find(:all, :order => "installed, activated DESC, name"),
  #    assigns(:features),
  #    "All features should match"
  #end
end
