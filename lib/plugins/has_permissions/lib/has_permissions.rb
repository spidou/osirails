module HasPermissions
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods    
    PERM_METHODS = %W{ list view add edit delete }
    
    def has_permissions *options
      
      if options.empty?
        add_instance_permission_methods
      end
      
      options.each do |option|
        if option == :as_business_object
          add_business_object_permission_methods
        end
      end
      
      declare_private_permissions_methods
    end
    
    def setup_has_permissions_model options = {}
      return unless !defined?(self.permissions_association_options) # don't allow multiple calls
      
      cattr_accessor :permissions_association_options
      
      self.permissions_association_options  = {
                                                :name => "#{self.name.tableize.singularize}_permissions".to_sym,
                                                :class_name => "#{self.name}Permission",
                                                :foreign_key => "#{self.name.tableize.singularize}_id".to_sym,
                                                :dependent => :destroy
                                              }.merge(options[:association_options] || {})
      
      # set up callback
      class_eval do
        after_create :create_permissions
        
        private 
          def create_permissions
            Role.find(:all).each do |role|
              permission_class = permissions_association_options[:class_name]
              foreign_key = permissions_association_options[:foreign_key]
              raise NameError, "#{ppermission_class} is not a valid class" unless Object.const_defined?(permission_class)
              permission_class.constantize.create(foreign_key => self.id, :role_id => role.id)
            end
          end
      end
      
      # set up association
      has_many self.permissions_association_options.delete(:name), self.permissions_association_options
    end
    
    def add_instance_permission_methods
      PERM_METHODS.each do |method|
        class_eval <<-EOL
          def can_#{method}?(user_or_role = nil)
            can_do?("#{method}", user_or_role)
          end
        EOL
      end
    end
    
    def add_business_object_permission_methods
      bo = BusinessObject.find_or_create_by_name(self.name.titleize)
          
      write_inheritable_attribute(:business_object_id, bo.id)
      write_inheritable_attribute(:business_object, bo)
      
      class_eval do
        def self.business_object?
          true
        end
        
        def self.business_object_id
          read_inheritable_attribute(:business_object_id)
        end
        
        def self.business_object
          read_inheritable_attribute(:business_object)
        end
      end
      
      PERM_METHODS.each do |method|
        class_eval <<-EOL
          def self.can_#{method}?(user_or_role = nil)
            can_do?("#{method}", user_or_role)
          end
        EOL
      end
    end
    
    def declare_private_permissions_methods
      class_eval do
        private
          def can_do?(action, user_or_role)
            self.class.get_permissions(action, user_or_role, self)
          end
          
          def self.can_do?(action, user_or_role)
            get_permissions(action, user_or_role)
          end
          
          # Permits to retrieve permissions to do an action (list/view/add/edit/delete) about a given object or model
          #   +action+        tells WHICH ACTION we want get permission. It must be a string within "list, view, add, edit, and delete".
          #   +user_or_role+  tells for WHICH user or role we want to get permission.
          #   +object+        tells in WHAT KIND of object we want to get permission.
          def self.get_permissions(action, user_or_role, object = nil)
            raise "#{action} is an unexepected action for permission control" unless good_action?(action)
            object ||= self # object represents an instance when it is called from an instance
                            # and a class when it is called from a class
                            # > We cannot use directly 'self' when it is called from an instance because we use a class method (self.get_permissions)
                            # and in this case, self return a class. So we have to pass 'self' in argument
            
            roles = get_roles(user_or_role)
            return false if roles.nil? or roles.empty?
            
            return_value = false
            roles.each do |role|
              raise TypeError, "The given argument is not an instance of Role. #{role}:#{role.class}" unless role.instance_of?(Role)
              next if return_value # skip test for other roles if one role match and return true
              
              ### INSTANCE METHODS
              if object.instance_of?(Calendar) # CALENDAR
                return true unless object.user_id.nil?
                perm = object.permissions.find_by_role_id(role, :conditions => { action => true })
              elsif object.instance_of?(Menu) # MENU
                perm = object.permissions.find_by_role_id(role, :conditions => { action => true })
              elsif object.class.ancestors.include?(ActionController::Base) # CONTROLLER > MENU
                perm = Menu.find_by_name(controller_path).permissions.find_by_role_id(role, :conditions => { action => true })

              ### CLASS METHODS
              elsif object.respond_to?("business_object?") # BUSINESS OBJECT
                perm = object.business_object.permissions.find_by_role_id(role, :conditions => { action => true })          
              else
                raise "I don't know what to do with that : object => #{object}:#{object.class}; user_or_role => #{user_or_role}:#{user_or_role.class}'"
              end
              return_value ||= perm.send(action) unless perm.nil?
            end
            
            return_value
          end
          
          def self.get_roles(object)
            roles = []
            if object.instance_of?(User)
              roles = object.roles
            elsif object.instance_of?(Role)
              roles << object
            elsif object.instance_of?(Fixnum)
              roles << Role.find(object)
            elsif object.instance_of?(String)
              roles << Role.find_by_name(object)
            elsif object.instance_of?(Array)
              roles = object
            else
              raise ArgumentError, "Not a valid argument passed in 'get_roles'. #{object}:#{object.class}"
            end
          end
          
          def self.good_action?(action)
            PERM_METHODS.include?(action)
          end
      end
    end
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasPermissions)
end

if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, HasPermissions)
end
