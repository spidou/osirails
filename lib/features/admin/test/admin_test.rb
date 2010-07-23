require 'test/test_helper'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures/'

class Test::Unit::TestCase
  fixtures :all

  def init_menus_and_permissions
    Feature::FEATURES_TO_ACTIVATE_BY_DEFAULT.each do |feature|
      yaml_path = File.join('lib/features', feature, 'config.yml')
      next unless File.exists?(yaml_path)
      
      yaml = YAML.load(File.open(yaml_path))

      @all_menus = []
      def load_menus(menus, parent_name = nil)
        menus.each_pair do |menu, options|
          parent = Menu.create :name => menu, :title => options["title"], :description => options["description"], :parent => parent_name, :position => options["position"], :hidden => options["hidden"]
          unless options["children"].nil?
            load_menus(options["children"], parent)
          end
        end
      end

      load_menus(yaml['menus'])
    end

    role = Role.create :name => 'all_permissions'
    User.all.each do |user|
      user.roles << role
      user.save
    end

    Permission.all.each do |permission|
      permission.permissions_permission_methods.each do |object_permission|
        object_permission.update_attribute(:active, true)
      end
    end

    true
  end

  def logged_as(user)
    @request.session[:user_id] = users(user).id
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
