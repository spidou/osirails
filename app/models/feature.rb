class Feature < ActiveRecord::Base
  serialize :dependencies
  serialize :conflicts
  
  @missing_dependencies = []
  @feature_conflicts = []
  
  def installed?
    self.installed
  end
    
  def activated?
    self.activated
  end
  
  def has_dependencies?
    if self.dependencies != nil
      self.dependencies.size > 0
    else
      false
    end
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
    if self.conflicts != nil
        self.conflicts.size > 0
    else
        false
    end
  end
  
  def installable?
    return true if !has_dependencies? and !has_conflicts?
    @missing_dependencies ||= []
    if has_dependencies?
      dependencies.each do |dep|
        if Feature.find(:all, :conditions =>["name=? and version in (?) ",dep[:name], dep[:version]]).size == 0
           @missing_dependencies << dep
        end     
      end
    end
    if @missing_dependencies.size > 0
      false
    else
      true
    end
  end
  
  def able_to_activate?
  end
  
  def able_to_deactivate?
  end
  
  def enable
  end
  
  def disable
  end
  
  def install
  end
  
  def uninstall
  end
  
  def remove
  end
  
  def check
  end
end
