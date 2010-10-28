class Watching < ActiveRecord::Base
  belongs_to :watchable, :polymorphic => true
  
  has_many :watchings_watchable_functions
  has_many :watchable_functions, :through => :watchings_watchable_functions
  
  has_many :on_modification_watchable_functions,  :through    => :watchings_watchable_functions,
                                                  :source     => :watchable_function,
                                                  :conditions => ["watchings_watchable_functions.on_modification = ?", true]
  
  has_many :on_schedule_watchable_functions,      :through    => :watchings_watchable_functions,
                                                  :source     => :watchable_function,
                                                  :conditions => ["watchings_watchable_functions.on_schedule = ?", true]
  
  validates_presence_of :watchable_type, :watchable_id, :watcher_id
  validates_presence_of :watchable, :if => :watchable_id
  validates_presence_of :watcher,   :if => :watcher_id
  
  validates_uniqueness_of :watchable_id, :scope => [:watchable_type, :watcher_id]
  
  validates_associated :watchings_watchable_functions
  
  before_validation :mark_to_destroy_unselected_items
  
  after_save :save_watchings_watchable_functions, :destroy_myself
  
  attr_accessor :should_destroy
  attr_accessor :all_changes_tmp
  
  def should_destroy?
    should_destroy
  end
  
  def all_watchings_watchable_functions_should_be_destroyed?
    watchings_watchable_functions.reject(&:should_destroy?).empty?
  end
  
  def mark_to_destroy_unselected_items
    watchings_watchable_functions.reject(&:selected?).each{ |n| n.should_destroy = true }
  end
  
  def build_missing_watchings_watchable_functions
    return unless watchable
    
    watchable.watchable_functions.each do |watchable_function|
      unless watchings_watchable_functions.detect{ |w| w.watchable_function_id == watchable_function.id }
        watchings_watchable_functions.build(:watchable_function_id => watchable_function.id)
      end
    end
  end
  
  def watchings_watchable_functions_attributes=(watchable_attributes)
    watchable_attributes.each do |attributes|
      if attributes[:id].blank?
        watchings_watchable_functions.build(attributes)
      else
        watchings_watchable_function = self.watchings_watchable_functions.detect{ |t| t.id == attributes[:id].to_i }
        watchings_watchable_function.attributes = attributes
      end
    end
  end
  
  def save_watchings_watchable_functions
    watchings_watchable_functions.each do |f|
      if f.should_destroy?
        f.destroy unless f.new_record?
      else
        f.save(false)
      end
    end
  end
  
  def destroy_myself #TODO is this really necessary ? can't we do that another way ?
    if (!all_changes && all_watchings_watchable_functions_should_be_destroyed?)
      self.destroy
    end
  end
end
