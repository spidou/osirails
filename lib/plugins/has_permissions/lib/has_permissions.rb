module HasPermissions
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods    
    DEFAULT_CLASS_METHODS =    [ :list, :view, :add, :edit, :delete ]
    DEFAULT_INSTANCE_METHODS = [ :list, :view, :add, :edit, :delete ]
    
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
      
      self.permissions_definitions ||= { :class_permission_methods    => DEFAULT_CLASS_METHODS,
                                         :instance_permission_methods => DEFAULT_INSTANCE_METHODS }
      
      class_eval do
        def self.all_permission_methods
          (self.permissions_definitions[:class_permission_methods] + self.permissions_definitions[:instance_permission_methods]).uniq
        end
      end
      
      params = options.last.is_a?(Hash) ? options.pop : {}
      
      if options.empty?
        
        if params[:additional_instance_methods]
          raise "[has_permissions] :additional_instance_methods expected to be an array" unless params[:additional_instance_methods].is_a?(Array)
          self.permissions_definitions.merge!(:instance_permission_methods => DEFAULT_INSTANCE_METHODS + params[:additional_instance_methods])
        elsif params[:instance_methods]
          raise "[has_permissions] :instance_methods expected to be an array" unless params[:instance_methods].is_a?(Array)
          self.permissions_definitions.merge!(:instance_permission_methods => params[:instance_methods])
        end
        
        add_instance_permission_methods
        
      else
        options.each do |option|
          if option == :as_business_object
            
            if params[:additional_class_methods]
              raise "[has_permissions] :additional_class_methods expected to be an array" unless params[:additional_class_methods].is_a?(Array)
              self.permissions_definitions.merge!(:class_permission_methods => DEFAULT_CLASS_METHODS + params[:additional_class_methods])
            elsif params[:class_methods]
              raise "[has_permissions] :class_methods expected to be an array" unless params[:class_methods].is_a?(Array)
              self.permissions_definitions.merge!(:class_permission_methods => params[:class_methods])
            end
            
            add_business_object_permission_methods
          end
        end
      end
      
      self.all_permission_methods.each do |method|
        PermissionMethod.find_or_create_by_name(method.to_s)
      end
      
      declare_private_permission_methods
    end
    
    def setup_has_permissions_model options = {}
      return false unless !defined?(self.permissions_association_options) # don't allow multiple calls
      
      cattr_accessor :permissions_association_options
      
      self.permissions_association_options  = {
                                                :name         => :permissions,
                                                :as           => :has_permissions,
                                                :class_name   => "Permission",
                                                :foreign_key  => :has_permissions_id,
                                                :dependent    => :destroy,
                                                :include      => :role
                                              }.merge(options[:association_options] || {})
      
      # set up association
      has_many self.permissions_association_options.delete(:name), self.permissions_association_options
      
      # set up callback
      class_eval do
        after_create :create_permissions
        
        private 
          def create_permissions
            Role.all.each do |role|
              permission = Permission.create!(:has_permissions_id   => self.id,
                                              :has_permissions_type => self.class.class_name,
                                              :role_id              => role.id)
              
              klass = self.is_a?(BusinessObject) ? self.name.constantize : self.class
              klass.all_permission_methods.each do |method|
                PermissionsPermissionMethod.create!(:permission_id        => permission.id,
                                                    :permission_method_id => PermissionMethod.find_by_name(method.to_s).id)
              end
            end
          end
      end
    end
    
    def add_instance_permission_methods
      self.permissions_definitions[:instance_permission_methods].each do |method|
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
        
        def self.business_object_id
          read_inheritable_attribute(:business_object_id)
        end
        
        def self.business_object
          read_inheritable_attribute(:business_object)
        end
      end
      
      self.permissions_definitions[:class_permission_methods].each do |method|
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
            raise "[has_permissions] #{action} is an unexepected action for permission control for #{self} > #{self.all_permission_methods.inspect}" unless good_action?(action)
            object ||= self # object represents an instance when it is called from an instance
                            # and a class when it is called from a class
                            # > We cannot use directly 'self' when it is called from an instance because we use a class method (self.get_permissions)
                            # and in this case, self return a class. So we have to pass 'self' in argument
            
            roles = get_roles(user_or_role)
            return false if roles.nil? or roles.empty?
            
            return_value = false
            roles.each do |role|
              raise TypeError, "[has_permissions] The given argument is not an instance of Role. #{role}:#{role.class}" unless role.instance_of?(Role)
              next if return_value # skip test for other roles if one role match and return true
              
              ### INSTANCE METHODS
#              if object.instance_of?(Calendar) # CALENDAR
#                return true unless object.user_id.nil?
#                perm = object.permissions.find_by_role_id(role)
              if object.class.respond_to?(:permissions_association_options) # Menu, DocumentType and any models which call the method "setup_has_permissions_model"
                perm = object.permissions.find_by_role_id(role)
              elsif object.instance_of?(Document)
                perm = object.document_type.permissions.find_by_role_id(role)

              ### CLASS METHODS
              elsif object.respond_to?("business_object?") # BUSINESS OBJECT
                perm = object.business_object.permissions.find_by_role_id(role)
              else
                raise "[has_permissions] I don't know what to do with that : object => #{object}:#{object.class}; user_or_role => #{user_or_role}:#{user_or_role.class}'"
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
              raise ArgumentError, "[has_permissions] Not a valid argument passed in 'get_roles'. #{object}:#{object.class}"
            end
          end
          
          def self.good_action?(action)
            self.all_permission_methods.include?(action.to_sym)
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
