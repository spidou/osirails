module ActsAsWatchable
  class ActsAsWatchableError < StandardError #:nodoc:
  end
  
  class ActsAsWatchableMultipleCallError < ActsAsWatchableError #:nodoc:
  end
  
  class << self
    def included(base) #:nodoc:
      base.extend ClassMethods
    end
  end
  
  #FIXME Default functions need to be reviewed because it's not very clear.
  #      detect_changes is based on the field 'all_changes' on the 'watchings' table.
  #      Right now, it's impossible to use additionnal default functions (like 'detect_all_changes')
  
  DEFAULT_NOTIFICATION_FUNCTIONS = [ :detect_changes, :detect_all_changes ] # :detect_all_changes is unused for now
  
  module ClassMethods
    
    def acts_as_watchable(options = {})
      cattr_accessor :watchable_identifier_method
      
      self.watchable_identifier_method = options[:identifier_method] || :to_s
      
      class_eval do
        validates_associated :watchings
        after_save :save_watchings
        
        include ActsAsWatchableInstanceMethods
      end
    end
    
    def acts_as_watcher(options = {})
      cattr_accessor :watcher_identifier_method, :watcher_email_method
      
      self.watcher_identifier_method = options[:identifier_method] || :to_s
      
      if ActsAsWatchable.const_defined?("WatcherClassName") && self.name != ActsAsWatchable::WatcherClassName
        raise ActsAsWatchableMultipleCallError, "acts_as_watcher must be defined just once. You have defined act_as_watcher on #{ActsAsWatchable::WatcherClassName}."
      else
        ActsAsWatchable.const_set("WatcherClassName", self.name) unless ActsAsWatchable.const_defined?("WatcherClassName")
      end
      
      if options[:email_method]
        self.watcher_email_method = options[:email_method]
      else
        raise ArgumentError, "acts_as_watcher expected at least the 'email_method' name"
      end
      
      Watching.class_eval do
        belongs_to :watcher, :class_name => ActsAsWatchable::WatcherClassName
      end
      
      # prepare instance variables
      class_eval do
        include ActsAsWatcherInstanceMethods
      end
    end
    
  end
  
  module ActsAsWatchableInstanceMethods
    
    def watchable_functions # has_many :watchable_functions seems to not always work very well
      WatchableFunction.all(:conditions => ["watchable_type = ?", self.class.name])
    end
    
    def watchable_function_ids # redefine because has_many with finder_sql seems to be unable to retrieve ids
      watchable_functions.collect(&:id)
    end
    
    def watchable_identifier
      send(watchable_identifier_method)
    end
    
    def watchings
      Watching.all(:conditions => ["watchable_type = ? AND watchable_id = ?", self.class.name, id])
    end
    
    def all_changes_watchings
      Watching.all(:conditions => ["watchable_type = ? AND watchable_id = ? AND all_changes = 1", self.class.name, id])
    end
    
    def update
      detect_changes_on_object if attributes_changed?(attributes.keys)
      run_throught_watchable_function
      super
    end
    
    def can_execute_instance_method?(watchable_function)
      respond_to?(watchable_function.name)
    end
    
    def execute_instance_method(watchable_function)
      send(watchable_function.name) if can_execute_instance_method?(watchable_function)
    end
    
    def attributes_changed?(attributes_to_verify)
      changed.each do |changed_key|
        attributes_to_verify.each do |key|
          return true if changed_key == key 
        end
      end
      return false
    end
    
    def save_watchings
      for watching in watchings
        if watching.should_destroy?
          watching.destroy
        else
          watching.save(false)
        end
      end
    end
    
    def watchings_attributes=(watching_attributes)
      watching_attributes.each do |attributes|
        if attributes[:id].blank?
          watchings.build(attributes)
        else
          watching = watchings.detect{ |t| t.id == attributes[:id].to_i }
          watching.attributes = attributes
        end
      end
    end
    
    def deliver_email_for(watchable_function, watching)
      return unless should_deliver_email_for?(watchable_function)
      
      if watching.watcher.watcher_email #TODO shouldn't we test if email is well-formed here?
        NotificationMailer.deliver_notification_email(self, watching.watcher.watcher_email,
                                                      watchable_function.name)
      else
        #TODO log that anywhere
      end
    end
    
    def should_deliver_email_for?(watchable_function)
      execute_instance_method(watchable_function) || watchable_function.execute_class_method
    end
    
    def find_watching_with(user_id)
      watchings.detect{ |n| n.watcher_id == user_id }
    end
    
    def already_watched_by?(user)
      find_watching_with(user.id)
    end
    
    def not_watched_by?(user)
      !already_watched_by?(user)
    end
    
    private
      def detect_changes_on_object
        for watching in all_changes_watchings
          if watching.watcher.watcher_email
            NotificationMailer.deliver_notification_email(self, watching.watcher.watcher_email,
                                                          :detect_changes)
          else
            #TODO log that anywhere
          end
        end
      end
      
      def run_throught_watchable_function
        for watching in watchings
          for watchable_function in watching.on_modification_watchable_functions
            deliver_email_for(watchable_function, watching)
          end
        end
      end
      
  end
  
  module ActsAsWatcherInstanceMethods
    
    def watcher_identifier
      send(watcher_identifier_method)
    end
    
    def watcher_email
      send(watcher_email_method)# if respond_to?(watcher_email_method)
    end
    
    def watcher_type
      self.class.name
    end
    
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  if defined?(I18n)
    I18n.load_path += Dir[ File.join(RAILS_ROOT, 'lib', 'plugins', 'acts_as_watchable', 'config', 'locale', '*.{rb,yml}') ]
    I18n.reload!
  end
  ActiveRecord::Base.send(:include, ActsAsWatchable)
end
