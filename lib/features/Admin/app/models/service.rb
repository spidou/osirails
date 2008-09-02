class Service < ActiveRecord::Base
  
  # Relationship
  has_many :employees_services
  has_many :employees, :through => :employees_services
  belongs_to :parent_service, :class_name =>"Service", :foreign_key => "service_parent_id"
  has_many :schedules
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "service_parent_id"
  
  # Validation Macros
  validates_presence_of :name, :message => "ne peut être vide"

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
  def Service.get_structured_services(indent,current_service_id = nil)
    services = Service.find_all_by_service_parent_id
    service_parents = []
    root = Service.new
    root.name = "  "
    root.id = nil
    get_children_services(services, current_service_id, service_parents,indent)
  end
  
  # This method permit to have children for services
  def Service.get_children_services(services, current_service_id, service_parents, indent)
    services.each do |service|
      unless service.id == current_service_id
      service.name = indent * service.ancestors.size + service.name if service.name != nil
      service_parents << service
      if service.children.size > 0
        get_children_services(service.children, current_service_id , service_parents, indent)
      end
      end
    end
    service_parents
  end
  
  def can_delete?
    return false if self.employees.size > 0 or self.children.size > 0
    true
  end
  
  # method to return the params[:schedules] hash completed with the form values 
  def get_time(day,chaine)
  
    schedules = chaine.split("|")
    formated_schedules = []
    schedules_hash = {}
    
    schedules.each_with_index do |f,index|
      value = f.split(' H ')

      value==[] ? tmp = nil : tmp = value[0].to_i  
      tmp.nil? ? tmp = nil : tmp += value[1].to_i.minutes.to_f / 3600

      formated_schedules << tmp
    end
    
    schedules_hash[:day] = Time::R_DAYS[day]
    schedules_hash[:morning_start] = formated_schedules[0]
    schedules_hash[:morning_end] = formated_schedules[1]
    schedules_hash[:afternoon_start] = formated_schedules[2]
    schedules_hash[:afternoon_end] = formated_schedules[3]
    
    return schedules_hash
  end
  
  def schedule_find (service=self)
    while !service.parent.nil?
      if service.schedules == []
        service = service.parent
      else
        return service
      end
    end
    return service 
  end
  
end
