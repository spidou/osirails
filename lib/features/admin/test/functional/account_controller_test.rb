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
    user = users(:one)
    post :login, {:username => user.username, :password => "password"}
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
end
