require 'test/test_helper'

class FeatureTest < ActiveSupport::TestCase
  fixtures :features

  def setup
    @normal_feature_one = features(:normal_feature1)
    @normal_feature_two = features(:normal_feature2)
    @feature_with_one_dep = features(:feature_with_one_dep)
    @feature_with_two_deps = features(:feature_with_two_deps)
    @feature_with_one_conflict = features(:feature_with_one_conflict)
  end

  def test_create
    assert_difference 'Feature.count', +1, "A Feature should be created" do
      Feature.create(:name => "test_create_feature",
                     :title => "Test Create Feature",
                     :version => 0.4,
                     :installed => true,
                     :activated => true)
    end
  end

  def test_read
    assert_nothing_raised "A Feature should be read" do
      Feature.find_by_name(@normal_feature_one.name)
    end
  end

  def test_update
    assert @normal_feature_one.update_attributes(:name => 'new_name'), "A Feature should be updated"
  end

  def test_delete
    assert_difference 'Feature.count', -1 do
      @normal_feature_one.destroy
    end
  end

  def test_presence_of_name
    assert_no_difference 'Feature.count' do
       feature = Feature.create(:name => '')
       assert_not_nil feature.errors.on(:name), "A Feature should not have a blank name"
     end
  end

  def test_uniqueness_of_name
    assert_no_difference 'Feature.count' do
       feature = Feature.create(:name => @normal_feature_one.name)
       assert_not_nil feature.errors.on(:name), "A Feature should have an uniq name"
     end
  end

  def test_presence_of_version
    @normal_feature_one.update_attributes(:version => nil)
    assert_not_nil @normal_feature_one.errors.on(:version), "A Feature should have a version"
  end

  def test_dependencies
    flunk "This Feature should have a dependency" unless @feature_with_one_dep.has_dependencies?

    assert @feature_with_one_dep.dependencies.include?({ :name => "normal_feature1", :version=> [0.1] }),
      "This Feature should have this specified dependency"
  end

  def test_child_dependencies
    # FIXME Fix the error that raise when call the method has_child_dependencies?
    # flunk "This Feature should have child dependencies" unless @feature_with_two_deps.has_child_dependencies?
  end

  def test_conflicts
    flunk "This Feature should have a conflict" unless @feature_with_one_conflict.has_conflicts?

    assert_equal @feature_with_one_conflict.conflicts,
      [{ :name=>"normal_feature1", :version=>[0.1] }],
      "This Feature should have this specified conflict"
  end

  def test_ability_to_add
    # TODO
  end

  def test_ability_to_remove
    @normal_feature_one.update_attributes(:installed => false, :activated => false)
    assert @normal_feature_one.able_to_remove?
  end

  def test_add
    # TODO Create an archive that contain a feature
    # assert Feature.add(archive_path)
  end

  def test_remove
    # TODO
    # assert @normal_feature_one.remove
  end

  def test_ability_to_install
    @normal_feature_one.update_attributes(:installed => false, :activated => false)
    assert @normal_feature_one.able_to_install?

    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    @feature_with_one_dep.update_attributes(:installed => false, :activated => false)
    assert @feature_with_one_dep.able_to_install?
    
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    @normal_feature_two.update_attributes(:installed => true, :activated => false)
    @feature_with_one_dep.update_attributes(:installed => true, :activated => false)
    @feature_with_two_deps.update_attributes(:installed => false, :activated => false)
    assert @feature_with_two_deps.able_to_install?
  end

  def test_unability_to_install
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    assert !@normal_feature_one.able_to_install?

    @normal_feature_one.update_attributes(:installed => false, :activated => false)
    @feature_with_one_dep.update_attributes(:installed => false, :activated => false)
    assert !@feature_with_one_dep.able_to_install?

    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    @normal_feature_two.update_attributes(:installed => true, :activated => false)
    @feature_with_one_dep.update_attributes(:installed => false, :activated => false)
    @feature_with_two_deps.update_attributes(:installed => false, :activated => false)
    assert !@feature_with_two_deps.able_to_install?

    assert !@feature_with_one_conflict.able_to_install?
    
    @feature_with_one_conflict.update_attributes(:installed => true, :activated => false)
    assert !@normal_feature_one.able_to_install?
  end

  def test_ability_to_uninstall
    @feature_with_one_dep.update_attributes(:installed => false, :activated => false)
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    assert @normal_feature_one.able_to_uninstall?
  end

  def test_unability_to_uninstall
    @feature_with_one_dep.update_attributes(:installed => true, :activated => false)
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    assert !@normal_feature_one.able_to_uninstall?
  end

  def test_installation
    @normal_feature_one.update_attributes(:installed => false, :activated => false)
    @normal_feature_one.install
    assert @normal_feature_one.installed?, "This Feature should be installed"
  end

  def test_uninstallation
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    @normal_feature_one.uninstall
    assert !@normal_feature_one.installed?, "This Feature should be uninstalled"
  end

  def test_ability_to_activate
    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    assert @normal_feature_one.able_to_activate?

    @normal_feature_one.update_attributes(:installed => true, :activated => true)
    @feature_with_one_dep.update_attributes(:installed => true, :activated => false)
    assert @feature_with_one_dep.able_to_activate?
  end

  def test_unability_to_activate
    @normal_feature_one.update_attributes(:installed => true, :activated => true)
    assert !@normal_feature_one.able_to_activate?

    @normal_feature_one.update_attributes(:installed => true, :activated => false)
    @feature_with_one_dep.update_attributes(:installed => true, :activated => false)
    assert !@feature_with_one_dep.able_to_activate?
  end

  def test_ability_to_deactivate
    @feature_with_one_dep.update_attributes(:installed => true, :activated => false)
    @normal_feature_one.update_attributes(:installed => true, :activated => true)
    assert @normal_feature_one.able_to_deactivate?
  end

  def test_unability_to_deactivate
    @feature_with_one_dep.update_attributes(:installed => true, :activated => true)
    @normal_feature_one.update_attributes(:installed => true, :activated => true)
    assert !@normal_feature_one.able_to_deactivate?
  end

  def test_activation
    @normal_feature_one.enable
    assert @normal_feature_one.activated?, "This Feature should be activate"
  end

  def test_deactivation
    @normal_feature_one.disable
    assert !@normal_feature_one.activated?, "This Feature should be disabled"
  end
end
