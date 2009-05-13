require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  require "digest/sha1"

  def setup
    @user_one = users(:admin_user)
    @user_two = users(:powerful_user)
  end

  def test_create
    assert_difference 'User.count', +1, "An User should be created" do
      user = User.create(:username => 'test_user',
                         :password => 'password',
                         :password_confirmation => 'password',
                         :enabled => true)
    end
  end

  def test_read
    assert_nothing_raised "An User should be read" do
      User.find_by_username(@user_one.username)
    end
  end

  def test_update
    assert @user_one.update_attributes(:username => 'new_username'), "A User should be updated"
  end

  def test_delete
    assert_difference 'User.count', -1 do
      @user_one.destroy
    end
  end

  def test_presence_of_username
    assert_no_difference 'User.count' do
      user = User.create(:username => '',
                         :password => 'password',
                         :password_confirmation => 'password',
                         :enabled => true)
      assert_not_nil user.errors.on(:username), "An User should not have a blank username"
    end
  end

  def test_presence_of_password
    assert_no_difference 'User.count' do
      user = User.create(:username => 'new_user',
                         :password => '',
                         :enabled => true)
      assert_not_nil user.errors.on(:password), "An User should have a password"
    end
  end

  def test_confirmation_of_password
    assert_no_difference 'User.count' do
      user = User.create(:username => 'new_user',
                         :password => 'password',
                         :enabled => true)
      assert_not_nil user.errors.on(:password_confirmation), "An User should have a confirmation of the password"
    end
  end

  def test_format_of_password
    # TODO
  end

  def test_encryption_of_password
    user = User.create(:username => 'foo',
                       :password => 'password',
                       :password_confirmation => 'password',
                       :enabled => true)
    assert_equal user.password, Digest::SHA1.hexdigest('password'), "A User should have an encrypted password"
  end

  def test_not_expired_password
    @user_one.update_attributes(:password_updated_at => Date.today - 1.day)
    ConfigurationManager.admin_password_validity = 30
    assert !@user_one.expired?, "This password should not be expired"
  end

  def test_expiration_of_password
    @user_one.update_attributes(:password_updated_at => nil)
    assert @user_one.expired?, "This password should be expired"
  end

  def test_expiration_of_password_refer_to_config
    ConfigurationManager.admin_password_validity = 0
    assert @user_one.expired?, "This password should be expired"
  end

  def text_expiration_of_password_refer_to_validity
    @user_one.update_attributes(:password_updated_at => Time.now + ConfigurationManager.admin_password_validity.day + 1.year)
    assert @user_one.expired?, "This password should be expired"
  end

  def test_update_password
    assert @user_one.update_attributes(:password => 'new_password',
                                       :password_confirmation => 'new_password')
  end

  def test_encryption
    assert_equal @user_one.encrypt('foo'), Digest::SHA1.hexdigest('foo'),
      "User should encrypt the password with SHA1"
  end
end