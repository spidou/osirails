class SupplyCategory < ActiveRecord::Base  
  # Validates
  validates_presence_of :name
  
  # This method prevents from remove if it is not authorized
  # Override is necessary because before_destroy callback 
  # used by the act_as_tree plugin empty all children before
  def destroy
    return false unless self.can_be_destroyed?
    super
  end
  
  # This method defines when it can be destroyed
  def can_be_destroyed?
    self.children.empty? and self.supplies.empty? and !self.has_children_disabled?
  end
  
  # This method defines when it can be disabled
  def can_be_disabled?
    self.enable and !self.has_children_enabled?
  end  
  
  # This method defines when it can be reactivated
  def can_be_reactivated?
    if self.parent.nil?
      !self.enable
    else
      !self.enable and self.parent.enable
    end
  end 
  
  # This method permit to disable a category
  def disable
    if self.can_be_disabled?
      self.enable = false
      self.disabled_at = Time.now
      self.save
    end
  end
  
  # This method permit to reactivate a category
  def reactivate
    if can_be_reactivated?
      self.enable = true
      self.disabled_at = nil
      self.save
    end
  end
  
  # This method determines if a category was enabled_at a given date
  def was_enabled_at(date=Date.today)
    self.enable or (!self.enable and self.disabled_at > date)
  end  
  
  # Check if a category have got children disabled
  def has_children_disabled?
    self.disabled_supplies.size > 0 or self.disabled_categories.size > 0
  end
  
  # Check if a category have got children enabled
  def has_children_enabled?
    self.enabled_supplies.size > 0 or self.enabled_categories.size > 0
  end
  
  # Returns the stock value according to its children category or 
  # directly to its supplies stock value
  def stock_value(date=Date.today)
    subordinates = (self.class.roots.include?(self) ? self.children : self.supplies)
    total = 0.0
    for subordinate in subordinates
      total += subordinate.stock_value(date) unless (!self.class.roots.include?(self) and !subordinate.was_enabled_at(date))
    end
    total
  end
end
