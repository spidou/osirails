module Permissible  
  module ClassMethode
    # The argument is a hash with these keys:
    # :user                 Is an user object
    # :controller_name      Correspond to the Menu name in the menus table.
    # If you specify controller_name, it means you use it in a controller to test the permissions for a menu.
    # Or if the controller_name is missing, it means you test the permissions for a Business Object,
    # so only use it in a Business Object model !
    def can_list? (options)
      can?("list", options[:user], options[:controller_name])
    end

    def can_view? (options)
      can?("view",options[:user], options[:controller_name])
    end

    def can_add? (options)
      can?("add",options[:user], options[:controller_name])
    end

    def can_edit? (options)
      can?("edit",options[:user], options[:controller_name])
    end

    def can_delete? (options)
      can?("delete",options[:user], options[:controller_name])
    end

    private
    def can?(action, user, controller_name = nil)
      raise "This method needs role." unless user.roles.size > 0
      raise "Unexepected action" unless ["list", "view", "add", "edit", "delete"].include?(action) # TODO Use constance for this array.
      return_value = false
      # If we want to test the permissions for a Business Object
      if controller_name == nil
        begin
        user.roles.each do |role|         
          perm = BusinessObjectPermission.find_by_has_permission_type_and_role_id(self.name, role, :conditions => {action => true})          
          return_value ||= perm.list unless perm.nil?
        end
        rescue NoMethodError
          logger.error "You must specify a controller or use it in a Business Object to use can?"
          return false
        end
      # If we want to test the permissions for a Menu
      else
        user.roles.each do |role|
          menu_id = Menu.find_by_name(controller_name)    
          perm = MenuPermission.find_by_menu_id_and_role_id(menu_id, role, :conditions => {action => true})          
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