module Osirails
  class Permission < ActiveRecord::Base
    belongs_to :has_permission, :polymorphic => true
    def self.can_list? (type, roles)
      self.can?("list", type, roles)
    end
    
    private
      def self.can?(action, type, roles)
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
end