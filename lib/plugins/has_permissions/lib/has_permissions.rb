module HasPermissions
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods    
    PERM_METHODS = %W{ list view add edit delete }
    
    def add_create_permissions_callback
      class_eval do
        after_create :create_permissions
        
        private 
          def create_permissions
            Role.find(:all).each do |r|
              permission_class = "#{self.class.name}Permission"
              field = "#{self.class.name.tableize.singularize}_id"
              raise NameError, "#{permission_class} is not a valid class" unless permission_class.constantize
              permission_class.constantize.create(field.to_sym => self.id, :role_id => r.id)
            end
          end
      end
    end
    
    def has_permissions *options
      options.each do |option|
        case option
        when :as_business_object
          bo = BusinessObject.find_or_create_by_name(self.name)
          
          write_inheritable_attribute(:business_object_id, bo.id)
          
          class_eval do
            def self.business_object?
              true
            end
            
            def self.business_object_id
              read_inheritable_attribute(:business_object_id)
            end
          end
          
        else
          raise ArgumentError, "Invalid argument #{option}:#{option.class}"
        end
      end
      
      PERM_METHODS.each do |method|
        class_eval <<-EOL
          def can_#{method}?(option = nil)
            can_do?("#{method}", option)
          end
          
          def self.can_#{method}?(option = nil)
            can_do?("#{method}", option)
          end
        EOL
      end
      
      class_eval do
        private
          def can_do?(action, object)
            roles = self.class.get_roles(action, object)
            
            return false if roles.nil?
            return false unless roles.size > 0
            
            return_value = false
            roles.each do |role|
              if role.class.equal?(String)
                tmp_role = Role.find_by_name(role)
                if tmp_role.nil?
                  raise "#{role} is not a valid role."
                else
                  role = tmp_role
                end
              end
              
              if self.class.equal?(Calendar) # If you want to test the permission of an user for an instance of Calendar who have not an owner.
                return true unless self.user_id.nil?
                perm = CalendarPermission.find_by_calendar_id_and_role_id(self.id, role, :conditions => {action => true})
              elsif self.class.equal?(Menu) # INSTANCE METHOD. If you want to know the permission of an user for a Menu.
                perm = MenuPermission.find_by_menu_id_and_role_id(self.id, role, :conditions => {action => true})
              elsif self.class.ancestors.include?(ActionController::Base) #!self.class.name.grep(/Controller$/).empty? # INSTANCE METHOD. If you call this method by a controller for verify if the user have the permission access for this controller.
                  menu = Menu.find_by_name(controller_path)
                  perm = MenuPermission.find_by_menu_id_and_role_id(menu.id, role, :conditions => {action => true})
              else
                raise "I don't know what to do with that : self => #{self}:#{self.class}; object => #{object}:#{object.class}'"
              end
              return_value ||= perm.send(action) unless perm.nil?
            end
            
            return_value
          end
        
          # You must pass 2 arguments for use this method:
          # action is a string like: list, view, add, edit, or delete.
          # object can be an User, a Role, a Role id, a Role name, or an array of Role / Role id / Role name.
          def self.can_do?(action, object)
            roles = get_roles(action, object)
            
            return false if roles.nil?
            return false unless roles.size > 0

            return_value = false
            roles.each do |role|
              if role.class.equal?(String)
                tmp_role = Role.find_by_name(role)
                if tmp_role.nil?
                  raise "#{role} is not a valid role."
                else
                  role = tmp_role
                end
              end
              
              if self.to_s == "Document"# && !document_model.nil?
                # CLASS METHOD. If you want to know the permission of an user for a Document by his model owner.
                perm = DocumentPermission.find_by_document_owner_and_role_id(document_model.to_s, role, :conditions => {action => true})
              elsif self.respond_to?("business_object?") # CLASS METHOD. If you want to know the permission of an user for a Business Object.
                perm = BusinessObjectPermission.find_by_business_object_id_and_role_id(self.business_object_id, role, :conditions => {action => true})          
              else
                raise "I don't know what to do with that : self => #{self}:#{self.class}; object => #{object}:#{object.class}'"
              end
              return_value ||= perm.send(action) unless perm.nil?
              
              ## TODO commiter tous ce qui est en rapport avec Document dans la branche document
              ## faire un backup du dossier osirails (au cas où le checkout dans la nouvelle branche me ferai perdre mes modifs!!)
              ## créer une branche (à partir de la branche document) pour les permissions et commiter toutes les modifs dans cette branche
            end

            return_value
          end
          
          def self.get_roles(action, object)
            raise "#{action} is an unexepected action for permission control" unless good_action?(action)
            roles = []
            case object.class
            when User.class
              roles = object.roles
            when Role.class, Fixnum.class
              roles << object
            when String.class
              roles << Role.find_by_name(object)
            when Array.class
              roles = object
            else
              raise ArgumentError, "Not a valid argument passed in can?"
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
