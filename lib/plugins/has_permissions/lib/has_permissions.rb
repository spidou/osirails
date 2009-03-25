module HasPermissions
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods    
    DEFAULT_METHODS = [ :list, :view, :add, :edit, :delete ]
    
    # has_permissions permits to configure permissions between roles and other kind of models
    # 
    # ==== Business Objects ====
    # TODO
    # 
    # === Examples
    #   class Klass < ActiveRecord::Base
    #     has_permissions :as_business_object
    #   end
    # 
    # ==== Menus ====
    # TODO
    #
    # === Examples
    # 
    # ==== Calendars ====
    # TODO
    #
    # === Examples
    # 
    # ==== Document Types =====
    # TODO
    #
    # === Examples
    #
    # ==== Custom permission methods ====
    # TODO
    #
    def has_permissions *options
      cattr_accessor :permissions_definitions
      
      self.permissions_definitions = { :permission_methods => DEFAULT_METHODS }
      
      if options.empty?
        add_instance_permission_methods
      end
      
      options.each do |option|
        if option.instance_of?(Hash)
          if option[:additional_methods]
            raise ":additional_methods expected to be an array" unless option[:additional_methods].instance_of?(Array)
            self.permissions_definitions = { :permission_methods => DEFAULT_METHODS + option[:additional_methods] }
          elsif option[:methods]
            raise ":methods expected to be an array" unless option[:methods].instance_of?(Array)
            self.permissions_definitions = { :permission_methods => option[:methods] }
          end
        end
      end
      
      options.each do |option|
        if option == :as_business_object
          add_business_object_permission_methods
        end
      end
      
      declare_private_permission_methods
    end
    
    def setup_has_permissions_model options = {}
      return unless !defined?(self.permissions_association_options) # don't allow multiple calls
      
      cattr_accessor :permissions_association_options
      
      self.permissions_association_options  = {
                                                :name => "#{self.singularized_table_name}_permissions".to_sym,
                                                :class_name => "#{self.name}Permission",
                                                :foreign_key => "#{self.singularized_table_name}_id".to_sym,
                                                :dependent => :destroy,
                                                :include => :role
                                              }.merge(options[:association_options] || {})
      
      # set up callback
      class_eval do
        after_create :create_permissions
        
        private 
          def create_permissions
            permission_class = permissions_association_options[:class_name]
            foreign_key = permissions_association_options[:foreign_key]
            raise NameError, "#{permission_class} is not a valid class" unless Object.const_defined?(permission_class)
            Role.all.each do |role|
              permission_class.constantize.create(foreign_key => self.id, :role_id => role.id)
            end
          end
      end
      
      # set up association
      has_many self.permissions_association_options.delete(:name), self.permissions_association_options
    end
    
    def add_instance_permission_methods
      self.permissions_definitions[:permission_methods].each do |method|
        class_eval <<-EOL
          def can_#{method}?(user_or_role = nil)
            can_do?("#{method}", user_or_role)
          end
        EOL
      end
    end
    
    def add_business_object_permission_methods
      bo = BusinessObject.find_or_create_by_name(self.name)
          
      write_inheritable_attribute(:business_object_id, bo.id)
      write_inheritable_attribute(:business_object, bo)
      
      class_eval do
        def self.business_object?
          true
        end
      end
      
      self.permissions_definitions[:permission_methods].each do |method|
        PermissionMethod.find_or_create_by_name(method.to_s)
        
        class_eval <<-EOL
          def self.can_#{method}?(user_or_role = nil)
            can_do?("#{method}", user_or_role)
          end
        EOL
      end
    end
    
    def declare_private_permission_methods
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
#              if object.instance_of?(Calendar) # CALENDAR
#                return true unless object.user_id.nil?
#                perm = object.permissions.find_by_role_id(role)
              if object.class.respond_to?(:permissions_association_options) # Menu, DocumentType and any models which call the method "setup_has_permissions_model"
                perm = object.permissions.find_by_role_id(role)
              elsif object.instance_of?(Document)
                perm = object.document_type.permissions.find_by_role_id(role)
              elsif object.class.ancestors.include?(ActionController::Base) # CONTROLLER > MENU
                (perm = Menu.find_by_name(controller_path).permissions.find_by_role_id(role)) rescue raise "permissions error for #{self}:#{self.class}"

              ### CLASS METHODS
              elsif object.respond_to?("business_object?") # BUSINESS OBJECT
                perm = object.business_object.permissions.find_by_role_id(role)
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
            self.permissions_definitions[:permission_methods].include?(action.to_sym)
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
