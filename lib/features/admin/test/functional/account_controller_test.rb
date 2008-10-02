require 'test_helper'
require File.dirname(__FILE__) + '/../admin_test'

require 'account_controller'

# re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase
  fixtures :users
  
  assert_valid_markup :index, :lost_password
  assert_valid_markup :expired_password, :but_first => :login_as_activated_but_has_expired_password_user
  
  def setup
    @controller = AccountController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_should_display_index_when_not_logged_in
    get :login
    assert_template "account/login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
    assert_response :success
  end
  
  def test_should_login_with_powerful_user
    login_as_powerful_user
    
    assert_response :redirect
    assert_redirected_to "permissions"
    assert_not_nil flash[:notice]
    assert_not_nil session[:user]
  end
  
  def test_should_not_login_with_unactivated_user_and_good_password
    login_as(:unactivated_user, "password")
    
    assert_not_nil flash[:error]
    assert_nil session[:user]
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_should_not_login_with_enabled_user_and_bad_password
    login_as(:powerful_user, "bad_password")
    
    assert_not_nil flash[:error]
    assert_nil session[:user]
    assert_redirected_to :controller => "account", :action => "login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_should_change_an_expired_password
    login_as_activated_but_has_expired_password_user
    
    raise @response.body.inspect
    assert_not_nil flash[:error], "flash[:error] should not be nil"
    assert_not_nil session[:user], "session[:user] should not be nil"
    assert_redirected_to :controller => "account", :action => "expired_password"
    follow_redirect
    submit_form do |form|
      form.user_password = "new P@ssw0rd"
      form.user_password_confirmation = "new P@ssw0rd"
    end
    assert @request.post?
  end
  
  def test_should_not_change_an_expired_password_because_of_same_old_password
    login_as_activated_but_has_expired_password_user
    
    raise @response.body.inspect
    assert_not_nil flash[:error], "flash[:error] should not be nil"
    assert_not_nil session[:user], "session[:user] should not be nil"
    assert_redirected_to :controller => "account", :action => "expired_password"
    follow_redirect
    submit_form do |form|
      form.user_password = "password"
      form.user_password_confirmation = "password"
    end
    assert @request.post?
  end
  
  def test_should_logout_when_logged_in
    login_as_powerful_user
    
    get :logout
    assert_not_nil flash[:notice]
    assert_redirected_to :controller => "account", :action => "login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_should_display_login_on_logout_when_not_logged_in
    get :logout
    assert_nil flash[:notice]
    assert_redirected_to :controller => "account", :action => "login"
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_should_not_display_lost_password_when_logged_in
    login_as(:powerful_user, "password")
    
    get :lost_password
    assert_response 302
    assert_not_routing "account/lost_password", {:controller => "account", :action => "lost_password"}
  end
  
  def test_should_display_lost_password_when_not_logged_in
    get :lost_password
    assert_response :success
    assert_routing "account/lost_password", {:controller => "account", :action => "lost_password"}
  end
  
  def test_should_send_lost_password_request_with_existant_user
    post :lost_password, {:username => users(:powerful_user).username}
    assert_not_nil flash[:notice]
    #raise flash[:error].inspect
    #raise @response.body.inspect
    assert_response 302
    assert_routing "account/lost_password", {:controller => "account", :action => "lost_password"}
  end
  
  def test_should_not_send_lost_password_request_with_unexistant_user_or_admin_user
    def lost_password_assertions
      assert_not_nil flash[:error]
      assert_response :success
      assert_template "account/lost_password"
    end
    # ask for new password with an unexistant user
    post :lost_password, {:username => "unexistant_user"}
    lost_password_assertions
    
    # ask for new password with the admin user
    post :lost_password, {:username => users(:admin_user).username}
    lost_password_assertions
  end
  
  def test_anti_flood_on_login
    #TODO test_anti_flood_on_login
  end
  
  def test_anti_flood_on_lost_password
    #TODO test_anti_flood_on_lost_password
  end
  
  def test_login_with_get_request
    get :login, {:username => users(:powerful_user).username, :password => "password"}
    assert_nil session[:user]
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
  def test_login_with_put_request
    put :login, {:username => users(:powerful_user).username, :password => "password"}
    assert_nil session[:user]
    assert_routing "account/login", {:controller => "account", :action => "login"}
  end
  
end
