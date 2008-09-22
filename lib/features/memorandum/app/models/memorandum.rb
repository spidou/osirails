class Memorandum < ActiveRecord::Base

  # Relationships
  has_many :memorandums_services
  has_many :services, :through => :memorandums_services
  
  # Validates
  validates_presence_of :title, :subject, :text, :signature, :message => ' ne peut etre vide.'

  # This method permit to find employee's memorandum
  def Memorandum.find_by_services(services)
    memorandums_services_list = []
    memorandums =[]
    services.each do |service|
      memorandums_services_list << service.memorandums_services
      if service.ancestors.size > 0
        service.ancestors.each do |parent_service|
          if parent_service.memorandums_services.size > 0

              parent_service.memorandums_services.delete_if { |memorandum_service| memorandum_service.recursive == false }
              memorandums_services_list << parent_service.memorandums_services

          end
        end
      end
    end
    memorandums_services_list.each do |memorandums_services|
      if memorandums_services.size > 0
        memorandums_services.each do |memorandum_service|
          memorandums << Memorandum.find(:first, :conditions => ["id = (?)", memorandum_service.memorandum_id])
        end
      end
      
    end
    
  memorandums
  end

  # This method permit to get recipient
  def Memorandum.get_recipient(memorandum)
    recipients = []
    services = memorandum.services
      services.each do |service|
      recipients << service.name
      end
    recipients.join(", ")
  end
  
  # This method permit to get employee information
  def Memorandum.get_employee(memorandum)
    user = User.find(memorandum.user_id)
    "#{user.employee.first_name} #{user.employee.last_name}"
  end
      
  # This method permit to structured date
  def Memorandum.get_structured_date(memorandum)
    if memorandum.published_at.nil?
      memorandum.updated_at.strftime('%d %B %Y')
    else
      memorandum.published_at.strftime('%d %B %Y')
    end
  end
  
end