require_dependency 'society_activity_sector'
require_dependency 'customer'
require_dependency 'establishment'
require_dependency 'society_activity_sector'
require_dependency 'application_helper'

class Customer
  has_many :orders

  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

class Establishment
  has_many :orders
end

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end

module ApplicationHelper
  private
    def current_menu # override the original current_menu method in ApplicationHelper
      step_menu = "#{controller.class.current_order_path}_orders" if controller.class.respond_to?("current_order_path")
      menu = step_menu || controller.controller_name
      Menu.find_by_name(menu) or raise "The controller '#{menu}' should have a menu with the same name"
    end
    
    def url_for_menu(menu) # override the original url_for_menu method in ApplicationHelper
      if menu.name
        path = "#{menu.name}_path"
        
        controller_name = "#{menu.name.camelize}Controller"
        begin
          controller_class = controller_name.constantize
          if controller_class.respond_to?(:current_order_path)
            path = "order_#{path}"
          end
        rescue NameError => e
          # do nothing if the controller doesn't exist, just stay the basic path pattern
        end
        
        if self.respond_to?(path)
          self.send(path)
        else
          url_for(:controller => menu.name)
        end
      else
        unless menu.content.nil?
          url_for(:controller => "contents", :action => "show", :id => menu.content.id)
        else
          ""
        end
      end
    end
end
