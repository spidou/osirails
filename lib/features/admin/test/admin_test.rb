class Test::Unit::TestCase
  fixtures :users

  def init_menus_and_permissions
    Feature::FEATURES_TO_ACTIVATE_BY_DEFAULT.each do |feature|
      yaml_path = File.join('lib/features', feature, 'config.yml')
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

    BusinessObjectPermission.all.each do |bop|
      bop.update_attributes :list => true, :view => true, :add => true, :edit => true, :delete => true
    end
    MenuPermission.all.each do |mp|
      mp.update_attributes :list => true, :view => true, :add => true, :edit => true, :delete => true
    end
    DocumentTypePermission.all.each do |dtp|
      dtp.update_attributes :list => true, :view => true, :add => true, :edit => true, :delete => true
    end
    CalendarPermission.all.each do |cp|
      cp.update_attributes :list => true, :view => true, :add => true, :edit => true, :delete => true
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