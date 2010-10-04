# module that gather methods necessary to notifier user on changement in model
# generation for the the models which implements it. 
# the model take or not attributes
#

module ActsAsWatchable
  class << self
    def included(base) #:nodoc:
      base.extend ClassMethods
    end
  end

  module ClassMethods
    
    def acts_as_watchable
      # prepare instance variables
      class_eval do
        include ActsAsWatchableInstanceMethods
        has_many :watchable_functions , :finder_sql => 'SELECT * FROM watchable_functions WHERE function_type = "#{self.class.name}"'
        
        validates_associated :watchables
        after_save :save_watchables
      end
    end
    
    def acts_as_watcher (options = {})
      cattr_accessor :watcher_email_method
      
      if !options.include?(:email_method) 
        raise ArgumentError, "Bad argument attribute use acts_as_watcher :email_method => :name_of_returning_email_method"
      else
        self.watcher_email_method = options[:email_method]
      end
      
      if  ActsAsWatchable.const_defined?("WatcherClassName") && self.name != ActsAsWatchable::WatcherClassName
        raise ArgumentError, "acts_as_watcher must be define just one time. You already define act_as_watcher on #{ActsAsWatchable::WatcherClassName} model."
      else
        ActsAsWatchable.const_set("WatcherClassName", self.name) unless ActsAsWatchable.const_defined?("WatcherClassName")
      end
      
      #raise ArgumentError, "Missing method error '#{self.watcher_email_method}' for model '#{ActsAsWatchable::WatcherClassName}'" unless  self.new.respond_to? self.watcher_email_method a supprimer
      
      Watchable.class_eval do
        belongs_to :watcher, :class_name => ActsAsWatchable::WatcherClassName
      end  
                
      # prepare instance variables
      class_eval do
        include ActsAsWatcherInstanceMethods
      end
    end
    
  end
  
  module ActsAsWatcherInstanceMethods

    def watcher_email
      self.send self.watcher_email_method if self.respond_to?(self.watcher_email_method)
    end
    
    def watcher_type
      self.class.name
    end
    
  end
  
  module ActsAsWatchableInstanceMethods  
    
    def watchables
      Watchable.all(:conditions => ["has_watchable_type = ? AND has_watchable_id = ?", self.class.name, self.id])
    end
    
    def all_changes_watchables
      Watchable.all(:conditions => ["has_watchable_type = ? AND has_watchable_id = ? AND all_changes = 1", self.class.name, self.id])
    end
    
    def update
      notify_modification_on_object if attributes_changed?(self.attributes.keys)
      run_throught_function 
      super
    end
    
    def can_execute_instance_method?(function)
      self.respond_to?(function.watchable_function.function_name)
    end

    def execute_instance_method(function)
      self.send(function.watchable_function.function_name) if can_execute_instance_method?(function)
    end
    
    def attributes_changed?(attributes_to_verify)
      changed.each do |changed_key|
        attributes_to_verify.each do |key|
          return true if changed_key == key 
        end
      end
      return false
    end
    
    def save_watchables
      for watchable in self.watchables
        if watchable.should_destroy?
          watchable.destroy
        else
          watchable.save(false)
        end
      end
    end
    
    def watchables_attributes=(watchable_attributes)
      watchable_attributes.each do |attributes|
        if attributes[:id].blank?
          self.watchables.build(attributes)
        else
          watchable = self.watchables.detect{ |t| t.id == attributes[:id].to_i }
          watchable.attributes = attributes
        end
      end
    end
    
    def deliver_email_for(function, watchable)
      if self.should_deliver_email_for?(function)
        NotificationMailer.deliver_notification_email(self, watchable.watcher.watcher_email, #"armoog_s@epitech.net"
                                                          function.watchable_function.function_name)
      end
    end
    
    def should_deliver_email_for?(function)
      execute_instance_method(function) || function.watchable_function.execute_class_method
    end
    
    def find_watchable_with(user_id)
      self.watchables.detect{|n| n.watcher_id == user_id}
    end  
    
    def can_watch?(current_user)
      (find_watchable_with(current_user.id) == nil) ? true : false
    end
    
    def can_edit_watchable?(current_user)
      !can_watch? current_user
    end     
    
    private
      
      def notify_modification_on_object
        for watchable in all_changes_watchables
          NotificationMailer.deliver_notification_email(self, 
                                                        watchable.watcher.watcher_email, "")#"armoog_s@epitech.net"
        end
      end
      
      def run_throught_function
        for watchable in watchables
          for function in watchable.on_modification_watchable_functions
            self.deliver_email_for(function, watchable)
          end
        end
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
