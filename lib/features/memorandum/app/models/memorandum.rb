class Memorandum < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationships
  has_many :memorandums_services
  has_many :services, :through => :memorandums_services
  belongs_to :user
  
  # Validates
  validates_presence_of :title, :subject, :text, :signature, :message => ' ne peut etre vide.'
  validates_associated :services, :memorandums_services
  
  # Name Scope
  named_scope :not_published, lambda { |current_user| {:conditions => ["published_at is null and user_id = ?", current_user]} }
  named_scope :published, lambda { |current_user| {:conditions => ["published_at is not null and user_id = ?", current_user]} }
  
  def published?
    published_at != nil
  end
  
  # This method permit to find employee's memorandum
  def Memorandum.find_by_services(services)
    memorandums_services_list = []
    memorandums =[]
    services.each do |service|
      memorandums_services_list << service.memorandums_services.reverse
      if service.ancestors.size > 0
        service.ancestors.each do |parent_service|
          if parent_service.memorandums_services.size > 0
            parent_service.memorandums_services.delete_if { |memorandum_service| memorandum_service.recursive == false }
            memorandums_services_list << parent_service.memorandums_services.reverse
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
  
  # This method permit to color memorandum list in table
  # 604800 respond_to one week period in seconds
  def Memorandum.color_memorandums(memorandum)

    unless memorandum.published_at.nil?
      time_now = Time.now
      period = time_now - memorandum.published_at
        if ( period < 604800 )
          return "new_memorandum"
        else
          return "old_memorandum"
        end
    else
      return "not_published_memorandum"
    end
  end
  
end
