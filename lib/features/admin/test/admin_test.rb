class Test::Unit::TestCase
  fixtures :users
  
  def login_as(user, password)
    old_controller = @controller.dup
    @controller = AccountController.new
    
    get :login
    assert_response :success
    submit_form do |form|
      form.username = users(user).username
      form.password = password
    end
    assert @request.post?
    
    @controller = old_controller
  end
  
  def login_as_powerful_user
    login_as(:powerful_user, "password")
  end
  
  def login_as_can_list_user
    login_as(:can_list_user, "password")
  end
  
  def login_as_can_view_user
    login_as(:can_view_user, "password")
  end
  
  def login_as_can_add_user
    login_as(:can_add_user, "password")
  end
  
  def login_as_can_edit_user
    login_as(:can_edit_user, "password")
  end
  
  def login_as_can_delete_user
    login_as(:can_delete_user, "password")
  end
  
  def login_as_activated_but_has_expired_password_user
    login_as(:activated_but_has_expired_password_user, "password")
  end
  
#  def login
#    old_controller = @controller.dup
#    @controller = AccountController.new
#    
#    login_as(:powerful_valid_user, "password")
#    
#    assert_response :redirect
#    assert_redirected_to "permissions"
#    assert_not_nil flash[:notice]
#    assert_not_nil session[:user_id]
#    @controller = old_controller
#  end
end