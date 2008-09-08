module Permissible  
  module InstanceMethods
    #protected # If you want to use the methods in console mode, you must comment this line.

    # document_model is a model used by DocumentPermissions.
    # example: .can_list?(user, Employee)
    
    def can_list?(option = nil, document_model = nil)
      can?("list", option, document_model)
    end

    def can_view?(option = nil, document_model = nil)
      can?("view", option, document_model)
    end

    def can_add?(option = nil, document_model = nil)
      can?("add", option, document_model)
    end

    def can_edit?(option = nil, document_model = nil)
      can?("edit", option, document_model)
    end

    def can_delete?(option = nil, document_model = nil)
      can?("delete", option, document_model)
    end

    private
      # You must pass 2 arguments for use this method:
      # action is a string like: list, view, add, edit, or delete.
      # option can be an User, a Role, a Role id, a Role name, or an array of Role / Role id / Role name.
      def can?(action, option, document_model)
        raise "Unexepected action" unless ["list", "view", "add", "edit", "delete"].include?(action) # TODO Use constance for this array.

        roles = []
        case option.class
        when User.class
          roles = option.roles
        when Role.class, Fixnum.class
          roles << option
        when String.class
          roles << Role.find_by_name(option)
        when Array.class
          roles = option
        else
          raise "Not a valid argument passed in can?"
        end

        return false if roles.nil?
        return false unless roles.size > 0

        return_value = false
        begin
          roles.each do |role|
            if role.class == String
              role = Role.find_by_name(role)
            end
            if self.class.name == "Document" && !document_model.nil?
              # CLASS METHOD. If you want to know the permission of an user for a Document by his model owner.
              perm = DocumentPermission.find_by_document_owner_and_role_id(document_model.to_s, role, :conditions => {action => true})
            elsif self.class.name == "Calendar"
              # INSTANCE METHOD. If you want to test the permission of an user for a Calendar who have not an owner.
              return true unless self.user_id.nil?
              perm = CalendarPermission.find_by_calendar_id_and_role_id(self.id, role, :conditions => {action => true})
            elsif !self.class.name.grep(/Controller$/).empty? #self.ancestors.include?(ActionController::Base) # INSTANCE METHOD. If you call this method by a controller for verify if the user have the permission access for this controller.
              menu = Menu.find_by_name(controller_path)    
              perm = MenuPermission.find_by_menu_id_and_role_id(menu.id, role, :conditions => {action => true})
            elsif self.class.name == "Menu" # INSTANCE METHOD. If you want to know the permission of an user for a Menu.
              perm = MenuPermission.find_by_menu_id_and_role_id(self.id, role, :conditions => {action => true})
            else # CLASS METHOD. If you want to know the permission of an user for a Business Object.
              perm = BusinessObjectPermission.find_by_has_permission_type_and_role_id(self.name, role, :conditions => {action => true})          
            end
            return_value ||= perm.list unless perm.nil?
          end
        rescue Exception => exc
          logger.error "Error when use can? method: " + exc
          return false
        end

        return_value     
      end
  end

  def self.included(klass)
    klass.extend(InstanceMethods)
  end
end