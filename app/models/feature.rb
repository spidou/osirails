class Feature < ActiveRecord::Base
  serialize :dependencies

  # Accessors  
  attr_reader :feature_conflicts, :missing_dependencies, :features_not_activated, :children_activated, :installation_messages, :features_uninstallable
  
  def installed?
    self.installed
  end
    
  def activated?
    self.activated
  end
  
  def has_dependencies?
    self.dependencies != nil and self.dependencies.size > 0 ? true : false
  end

  def child_dependencies
    dependencies = []
    Feature.find(:all).each do |feature|
      if feature.has_dependencies?
        feature.dependencies.each do |dependence|
          if dependence[:name] == self.name && dependence[:version].include?(self.version)
            dependencies << {:name => feature.name, :version => feature.version}
          end
        end
      end
    end
    dependencies
  end
  
  def has_child_dependencies?
    child_dependencies.size > 0
  end
  
  def has_conflicts?
    self.conflicts != nil and self.conflicts.size > 0 ? true : false
  end

  def installable?
    # Test if the current feature has conflicts or dependencies with other feature
    return true if !has_dependencies? and !has_conflicts?
    
    # Test if the current feature has a conflict with an installed feature
    @feature_conflicts = []
    if has_conflicts?
      conflicts.each do |conflict|
        if Feature.find(:all, :conditions => ["name=? and version in (?) and installed = 1", conflict[:name], conflict[:version]]).size > 0
           @feature_conflicts << conflict
        end     
      end
    end
    
    # Test if the current feature is not present in the conflicts list of all other features
    Feature.find(:all, :conditions => ["installed = 1"]).each do |feature|
      if feature.has_conflicts?
        feature.conflicts.each do |conflict|
          if conflict[:name] == self.name and conflict[:version].include?(self.version)
            @feature_conflicts << conflict
          end
        end
      end
    end
    
    # Test if the current feature's dependencies are installed
    @missing_dependencies = []
    if has_dependencies?
      dependencies.each do |dependence|
        if Feature.find(:all, :conditions => ["name=? and version in (?) and installed = 1", dependence[:name], dependence[:version]]).size == 0
           @missing_dependencies << dependence
        end     
      end
    end
    @feature_conflicts = @feature_conflicts.uniq
    @missing_dependencies = @missing_dependencies.uniq
    @missing_dependencies.size > 0 || @feature_conflicts.size > 0 ? false : true
  end
  
  def uninstallable?
    @features_uninstallable = []
    if !self.activated? and self.installed?
      self.child_dependencies.each do |child|
        if Feature.find(:all, :conditions =>["name = ? and version in (?) and activated = 1 or installed = 1", child[:name], child[:version]]).size > 0
          @features_uninstallable << child
        end
      end
    else
      return false
    end
    @features_uninstallable = @features_uninstallable.uniq
    @features_uninstallable.size > 0 ? false : true
  end
  
  def able_to_activate?
    return false if !self.installed? or self.activated?
    @features_not_activated = []
    self.dependencies.each do |dependence|
      if  Feature.find(:all, :conditions => ["name = ? and version in (?) and activated = 0", dependence[:name], dependence[:version]]).size > 0
        @features_not_activated << dependence
      end
    end
    @features_not_activated = @features_not_activated.uniq
    @features_not_activated.size > 0 ? false : true
  end 
  
  def able_to_deactivate?
    @children_activated = []
    self.child_dependencies.each do |child|
      if  Feature.find(:all, :conditions => ["name = ? and version in (?) and activated = 1", child[:name], child[:version]]).size > 0
        @children_activated << child
      end
    end
    @children_activated = @children_activated.uniq
    @children_activated.size > 0 or !self.activated? ? false : true
  end
  
  def enable
    if able_to_activate?
      self.activated = true
      if self.save 
        return true
      end
    end
    false
  end
  
  def disable
    if able_to_deactivate?
      self.activated = false
      if self.save
        return true
      end
    end
    false
  end
  
  def install
    if self.installable?
      @installation_messages = []
      require 'lib/features/'+self.name+'/install.rb'
      if feature_install
        self.installed = true
        if self.save
          return true
        end
      else 
        puts @installation_messages
        return false
      end
    end
  end
  
  def uninstall
    if self.uninstallable?
      @uninstallation_messages = []
      require 'lib/features/'+self.name+'/uninstall.rb'
      if feature_uninstall
        self.installed =false
        if self.save
          return true
        end
      else 
        puts @uninstallation_messages
        return false
      end
    end
  end
  
  def remove
  end
  
  def check
  end
end
