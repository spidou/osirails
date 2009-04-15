#require 'test_helper'
#
#class FeatureTest < ActiveSupport::TestCase
#  fixtures :features
#  
#  def test_validity_of_name
#    invalid_feature = Feature.new
#    assert_not_valid invalid_feature
#    assert invalid_feature.errors.invalid?(:name), invalid_feature.errors.full_messages
#    assert invalid_feature.save
#    
#    feature = Feature.new(:name => "feature")
#    assert_valid feature
#    assert feature.save
#    
#    same_feature = Feature.new(:name => "feature")
#    assert_not_valid same_feature
#    assert same_feature.errors.invalid?(:name), same_feature.errors.full_messages
#    assert !same_feature.save
#  end
#  
#  def test_installed
#    installed = %w{normal_feature1 normal_feature2 feature_with_one_dep feature_with_two_deps}
#    uninstalled = %w{feature_with_one_conflict feature_with_two_conflicts} 
#    
#    installed.each do |feature|
#      assert features(feature.to_sym).installed?
#    end
#    
#    uninstalled.each do |feature|
#      assert !features(feature.to_sym).installed?
#    end
#  end
#  
#  def test_activated
#    activated = %w{normal_feature1 normal_feature2 feature_with_one_dep feature_with_two_deps}
#    unactivated = %w{feature_with_one_conflict feature_with_two_conflicts} 
#    
#    activated.each do |feature|
#      assert features(feature.to_sym).activated?
#    end
#    
#    unactivated.each do |feature|
#      assert !features(feature.to_sym).activated?
#    end
#  end
#  
#  def test_dependencies
#    has_dependencies = %w{feature_with_one_dep feature_with_two_deps}
#    has_no_dependencies = %w{independant_feature normal_feature1 normal_feature2}
#    
#    has_dependencies.each do |feature|
#      assert features(feature.to_sym).has_dependencies?
#      assert !features(feature.to_sym).dependencies.empty?
#    end
#    
#    has_no_dependencies.each do |feature|
#      assert !features(feature.to_sym).has_dependencies?
#      raise features(feature.to_sym).inspect
#      assert features(feature.to_sym).dependencies.empty?
#    end
#  end
#  
#  def test_child_dependencies
#    has_child_dependencies = %w{normal_feature1 normal_feature2 feature_with_one_dep}
#    has_no_child_dependencies = %w{independant_feature feature_with_two_deps feature_with_one_conflict feature_with_two_conflicts}
#    
#    has_child_dependencies.each do |feature|
#      assert features(feature.to_sym).has_child_dependencies?
#    end
#    
#    has_no_child_dependencies.each do |feature|
#      assert !features(feature.to_sym).has_child_dependencies?
#    end
#  end
#  
#  def test_conflicts
#    has_conflicts = %w{feature_with_one_conflict feature_with_two_conflicts}
#    has_no_conflicts = %w{independant_feature normal_feature1 normal_feature2 feature_with_one_dep feature_with_two_deps}
#    
#    has_conflicts.each do |feature|
#      assert features(feature.to_sym).has_conflicts?
#    end
#    
#    has_no_conflicts.each do |feature|
#      assert !features(feature.to_sym).has_conflicts?
#    end
#  end
#  
#  def test_able_to_install
#    #TODO test_able_to_install
#  end
#  
#  def test_able_to_uninstall
#    #TODO test_able_to_uninstall
#  end
#  
#  def test_able_to_activate
#    #TODO test_able_to_activate
#  end
#  
#  def test_able_to_deactivate
#    #TODO test_able_to_deactivate
#  end
#  
#  def test_able_to_remove
#    #TODO test_able_to_remove
#  end
#  
#  def test_enabling
#    #TODO test_enabling
#  end
#  
#  def test_disabling
#    #TODO test_disabling
#  end
#  
#  def test_installing
#    #TODO test_installing
#  end
#  
#  def test_uninstalling
#    #TODO test_uninstalling
#  end
#  
#  def test_removing
#    #TODO test_removing
#  end
#end
#