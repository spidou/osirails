module Permissible  
  module ClassMethode
    def can_list? (options)
      can?("list", options[:type] ,options[:roles], options[:id])
    end

    def can_view? (options)
      can?("view",options[:type] ,options[:roles], options[:id])
    end

    def can_add? (options)
      can?("add",options[:type] ,options[:roles], options[:id])
    end

    def can_edit? (options)
      can?("edit",options[:type] ,options[:roles], options[:id])
    end

    def can_delete? (options)
      can?("delete",options[:type] ,options[:roles], options[:id])
    end

    private
    def can?(action, type, roles, id = nil)
      raise "This method needs role." unless roles.size > 0
      raise "Unexepected action" unless ["list", "view", "add", "edit", "delete"].include?(action) # TODO Use constance for this array.
      return_value = false
      if id == nil
        roles.each do |role|         
          perm = BusinessObjectPermission.find_by_has_permission_type_and_role_id(type, role, :conditions => {action => true})          
          return_value ||= perm.list unless perm.nil?
        end
      else
        roles.each do |role|         
          perm = PagePermission.find_by_page_id_and_role_id(id, role, :conditions => {action => true})          
          return_value ||= perm.list unless perm.nil?
        end           
      end
      return_value     
    end
  end

  def self.included(klass)
    klass.extend(ClassMethode)
  end
end