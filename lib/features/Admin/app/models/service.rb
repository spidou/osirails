class Service < ActiveRecord::Base
  
  # Relationship
  has_and_belongs_to_many :employees
  belongs_to :parent_service, :class_name =>"Service", :foreign_key => "service_parent_id"
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "service_parent_id"

  # Store the ancient services_parent_id before update_service_parent
  attr_accessor :old_service_parent_id, :update_service_parent
  
  # This method permit to check if a service can be a parent
  def before_update
    if self.update_service_parent
      if self.service_parent_id == nil
        true
      else
        new_parent_id, self.service_parent_id = self.service_parent_id, self.old_service_parent_id
        @new_parent = Service.find(new_parent_id)
        return false if @new_parent.id == self.id  or @new_parent.ancestors.include?(self)
        true
      end
    end
  end
  
  # This method apply configuration when before update return true
  def after_update
    if self.update_service_parent
      self.update_service_parent = false
      if self.service_parent_id == nil
        self.service_parent_id = nil
      else
        self.service_parent_id = @new_parent.id
        self.save
      end
    end
  end
  
  # This method permit to have structur for services
  def Service.get_structured_services(indent)
    services = Service.find_all_by_service_parent_id
    service_parents = []
    root = Service.new
    root.name = "  "
    root.id = nil
    service_parents = get_children_services(services,service_parents,indent)
    service_parents
  end
  
  def Service.get_children_services(services,service_parents, indent)
    services.each do |service|
      service.name = indent * service.ancestors.size + service.name if service.name != nil
      service_parents << service
      if service.children.size > 0
        get_children_services(service.children, service_parents, indent)
      end
    end
    service_parents
  end
end