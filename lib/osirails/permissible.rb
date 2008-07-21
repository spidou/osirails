module Osirails
  module Permissible  
    module ClassMethode
      def can_list? (type, roles)
      can?("list", type, roles)
    end
    
    def self.can_view? (type, roles)
      Permission.can?("view",type,roles)
    end
    
    def self.can_add? (type, roles)
      Permission.can?("add",type,roles)
    end
    
    def self.can_edit? (type, roles)
      Permission.can?("edit",type,roles)
    end
    
    def self.can_delete? (type, roles)
      Permission.can?("delete",type,roles)
    end
    
    private
      def can?(action, type, roles)
        raise "This method needs role." unless roles.size > 0
        raise "Unexepected action" unless ["list", "view", "add", "edit", "delete"].include?(action) # TODO Use constance for this array.
        return_value = false
        roles.each do |role|
          perm = Permission.find_by_has_permission_type_and_role_id(type, role, :conditions => {action => true})
          return_value ||= perm.list unless perm.nil?
        end
        return_value
      end
    end
    
    def self.included(klass)
      klass.extend(ClassMethode)
    end
  end
  
end