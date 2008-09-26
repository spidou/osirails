require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_index_when_not_logged_in
    get :index
    assert_template "account/login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
    assert_response :success
  end
  
  def test_login_when_not_logged_in
    get :login
    assert_response :success
  end
  
  def test_login_for_loggon_with_enabled_user_and_good_password
    login
    assert_not_nil flash[:notice]
    #TODO assert if redirection is good after login
  end
  
  def test_login_for_loggon_with_disabled_user_and_good_password
    user = users(:two)
    post :login, {:username => user.username, :password => "password"}
    assert_not_nil flash[:error]
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_login_for_loggon_with_enabled_user_and_bad_password
    user = users(:one)
    post :login, {:username => user.username, :password => "bad_password"}
    assert_not_nil flash[:error]
    assert_redirected_to :controller => "account", :action => "login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_lost_password_when_logged_in
    login
    get :lost_password
    assert_response 302
  end
  
  def test_lost_password_when_not_logged_in
    get :lost_password
    assert_response :success
  end
  
  def test_lost_password_with_existant_user
    user = users(:one)
    post :lost_password, {:username => user.username}
    assert_not_nil flash[:notice]
    assert_response 302
  end
  
  def test_lost_password_with_unexistant_user_or_admin_user
    def lost_password_assertions
      assert_not_nil flash[:error]
      assert_response :success
      assert_template "account/lost_password"
    end
    # ask for new password with an unexistant user
    post :lost_password, {:username => "unexistant_user"}
    lost_password_assertions
    
    # ask for new password with the admin user
    user = users(:admin)
    post :lost_password, {:username => user.username}
    lost_password_assertions
  end
  
  def test_anti_flood_on_login
    #TODO test_anti_flood_on_login
  end
  
  def test_anti_flood_on_lost_password
    #TODO test_anti_flood_on_lost_password
  end
  
  private
    def login
      user = users(:one)
      post :login, {:username => user.username, :password => "password"}
    end
end
