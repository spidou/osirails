class Watchable < ActiveRecord::Base
  
  belongs_to :has_watchable, :polymorphic => true
  
  has_many :watchables_watchable_functions
  has_many :watchable_functions, :through => :watchables_watchable_functions
  has_many :on_modification_watchable_functions, :class_name => 'WatchablesWatchableFunction', :conditions => ["on_modification = ?", 1]
  has_many :on_schedule_watchable_functions, :class_name => 'WatchablesWatchableFunction', :conditions => ["on_schedule = ?", 1]

  validates_associated :watchables_watchable_functions
  validates_presence_of :has_watchable_id, :has_watchable_type, :watcher_id
  validates_uniqueness_of :has_watchable_id, :scope => [:has_watchable_type, :watcher_id]
  
  before_validation :build_watchables_watchable_function
  after_save :save_watchables_watchable_functions
  after_save :destroy_watchable
  
  attr_accessor :should_destroy
  attr_accessor :all_changes_tmp
  
  def destroy_watchable
    if (!self.all_changes && all_watchables_watchable_functions_are_in_should_destroy?)
      self.destroy
    end
  end
  
  def all_watchables_watchable_functions_are_in_should_destroy?
    self.watchables_watchable_functions.reject{|n| n.should_destroy?}.empty?
  end
  
  def build_watchables_watchable_function
    self.watchables_watchable_functions.each{ |n|
      n.should_destroy = true unless n.selected? 
    }
  end
  
  def should_destroy?
      self.should_destroy ? true : false
  end
  
  def save_watchables_watchable_functions
    for watchables_watchable_function in self.watchables_watchable_functions
      if watchables_watchable_function.should_destroy?
        watchables_watchable_function.destroy unless watchables_watchable_function.new_record? 
      else
        watchables_watchable_function.save(false)
      end
    end
  end
  
  def build_watchables_watchable_function_with(watchable_functions)
    for watchable_function in watchable_functions
      unless (self.watchables_watchable_functions.detect{|n| n.watchable_function_id == watchable_function.id})
        self.watchables_watchable_functions.build({:watchable_function_id => watchable_function.id})
      end   
    end
    self.watchables_watchable_functions
  end 
  
  def watchables_watchable_functions_attributes=(watchable_attributes)
    watchable_attributes.each do |attributes|
      if attributes[:id].blank?
        self.watchables_watchable_functions.build(attributes)
      else
        watchable = self.watchables_watchable_functions.detect{ |t| t.id == attributes[:id].to_i }
        watchable.attributes = attributes
      end
    end
  end
  
end
