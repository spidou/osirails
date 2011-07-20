class Employee < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :curriculum_vitae, :driving_licence, :identity_card, :other
  
  has_numbers
  
  # restrict or add methods to be use into the pattern 'Attribut'
  METHODS = {'Employee' => ['last_name','first_name','birth_date'], 'User' =>[]}
  
  has_attached_file :avatar, 
                    :styles       => { :thumb => "100x100#" },
                    :path         => ":rails_root/assets/rh/employees/:id/avatar/:style.:extension",
                    :url          => "/employees/:id.:extension",
                    :default_url  => ":current_theme_path/images/default_avatar.png"
  
  belongs_to :civility
  belongs_to :user
  belongs_to :service
  
  has_one :employee_sensitive_data
  
  has_many :job_contracts
  has_one  :job_contract, :class_name => 'JobContract', :conditions => ["start_date <= ? AND ( (end_date IS NULL AND departure IS NULL) OR (end_date IS NULL AND departure > ?) OR (end_date IS NOT NULL AND departure > ?) OR (departure IS NULL AND end_date > ?) )", Date.today, Date.today, Date.today, Date.today] # conditions have been copied from JobContract#actives
  has_many :employees_jobs
  has_many :jobs, :through => :employees_jobs
  has_many :checkings
  has_many :leaves, :class_name => "Leave", :order => "start_date DESC"
  has_many :leave_requests
  has_many :in_progress_leave_requests, :class_name => "LeaveRequest",
                                        :conditions => ["status IN (?)", [LeaveRequest::STATUS_SUBMITTED, LeaveRequest::STATUS_CHECKED, LeaveRequest::STATUS_NOTICED]],
                                        :order      => "noticed_at DESC, checked_at DESC, created_at DESC, start_date DESC"
  has_many :accepted_leave_requests,    :class_name => "LeaveRequest",
                                        :conditions => ["status = ?", LeaveRequest::STATUS_CLOSED],
                                        :order      => "updated_at DESC, start_date DESC"
  has_many :refused_leave_requests,     :class_name => "LeaveRequest",
                                        :conditions => ["status IN (?)", [LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR]],
                                        :order      => "updated_at DESC, start_date DESC"
  has_many :cancelled_leave_requests,   :class_name => "LeaveRequest",
                                        :conditions => ["status = ?", LeaveRequest::STATUS_CANCELLED],
                                        :order      => "cancelled_at DESC, start_date DESC"
  
  named_scope :actives, :include => [:job_contracts], :conditions => ["job_contracts.start_date <= ? AND ( (job_contracts.end_date IS NULL AND job_contracts.departure IS NULL) OR (job_contracts.end_date IS NULL AND job_contracts.departure > ?) OR (job_contracts.end_date IS NOT NULL AND job_contracts.departure > ?) OR (job_contracts.departure IS NULL AND job_contracts.end_date > ?) )", Date.today, Date.today, Date.today, Date.today] # conditions have been copied from JobContract#actives
  
  validates_presence_of :last_name, :first_name
  validates_presence_of :civility_id, :service_id
  validates_presence_of :civility,             :if => :civility_id
  validates_presence_of :service,              :if => :service_id
  
  validates_format_of :society_email,           :with         => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,
                                                :allow_blank  => true
  
  # papercilp plugin validations
  with_options :if => :avatar do |v|
    v.validates_attachment_content_type :avatar, :content_type => [ 'image/jpg', 'image/png','image/jpeg']
    v.validates_attachment_size         :avatar, :less_than => 2.megabytes
  end
  
  validates_associated :user, :employee_sensitive_data, :job_contracts
  
  validate :validates_responsible_job_limit
  
  journalize :attributes        => [ :first_name, :last_name, :civility_id, :service_id, :society_email ],
             :attachments       => :avatar,
             :subresources      => [ :employee_sensitive_data, :job_contracts, { :jobs => :create_and_destroy } ],
             :identifier_method => :fullname
  
  has_search_index  :only_attributes       => [ :id, :first_name, :last_name, :society_email],
                    :additional_attributes => { :fullname => :string },
                    :only_relationships    => [ :civility, :employee_sensitive_data, :job_contract, :job_contracts, :jobs, :service, :user ],
                    :identifier            => :fullname
  
  before_validation :build_associated_resources
  before_save :case_management
  after_save :save_employee_sensitive_data
  
  cattr_accessor :pattern_error
  @@pattern_error = false
  
  # Method to manage that there's no more than 2 responsible jobs by service
  def validates_responsible_job_limit
    unless jobs.empty?
      jobs.with_responsibility.group_by(&:service).to_hash.each_pair do |service, jobs_collection|
        max_responsible_jobs = (2 - service.responsibles.reject {|n| id==n.id}.size)
        #TODO replace this view logic by a new tag system
        jobs_names = jobs_collection.collect(&:name).join("<br/>- ")
        p = "poste#{"s" if max_responsible_jobs>1}"
        #TODO replace this view logic by a new tag system
        errors.add(:jobs, "Vous devez choisir #{max_responsible_jobs} #{p} parmi les postes suivants :<br/>- #{jobs_names}") if jobs_collection.size > max_responsible_jobs
      end
    end
  end
  
#  # method to get the employee's leaves days left
#  # ps : the argument is here just to permit another use by another method,
#  #      but to get the leaves days left for the employee and for the current year
#  #      no arguments are needed 
#  # n => permit to target a leave year .
#  #   #=> default is 0 and represent current leave year
#  #   #=> negative value represente shift to the past
#  #   #=> positive value represente shift to the future
#  #
#  def leaves_days_left(n = 0)   
#    l_year_start_date = leave_year_start_date + n.year                                                               
#    l_year_end_date =  leave_year_start_date + 1.year - 1.day
#    total = get_total_leave_days(n)
#    get_leaves_for_choosen_year(n).each do |l|
#      total -= l.duration
#      total += l.duration(l_year_end_date, l.end_date) - 1 if l.end_date > l_year_end_date
#      total += l.duration(l.start_date, l_year_start_date) - 1 if l.start_date < l_year_start_date
#    end
#    return total
#  end
  
#  # just rename a method to make the call, more human readable
#  def leaves_days_left_for_past_year
#    leaves_days_left -1
#  end

#  # method to get the current total of leave days available
#  def get_total_leave_days(n = 0)
#    l_year_start_date = self.class.leave_year_start_date + n
#    positive_difference = (l_year_start_date.month > Date.today.month)? 12 : 0
#    months = Date.today.month - l_year_start_date.month + positive_difference + 1
#    months = 12 if n < 0 # all days are already acquired if it's about past year
#    months = 0 if n > 0 # no days are acquired if it's about next year
#    ConfigurationManager.admin_society_identity_configuration_leave_days_credit_per_month * months
#  end
 
  # Method to get leaves for choosen leave year
  # all to true permit to get leaves including cancelled ones
  #
  def get_leaves_for_choosen_year(year, all = false)
    year_start = self.class.leave_year_start_date.change(:year => year.to_i)                                                               
    year_end = year_start + 1.year - 1.day
    
    collection = all ? leaves : leaves.actives
    collection.select {|n| n.end_date >= year_start and n.start_date <= year_end }
  end
  
  # Method to get leave requests that he has to check, as responsible
  def get_leave_requests_to_check
    LeaveRequest.find(:all, :conditions => ["status = ? AND employee_id IN (?)", LeaveRequest::STATUS_SUBMITTED, self.subordinates],
                            :order      => "start_date DESC")
  end
  
  # Method to get leave requests that he refused, as responsible or director
  def get_leave_requests_refused_by_myself
    LeaveRequest.find(:all, :conditions => ["(status = ? AND responsible_id = ?) OR (status = ? AND director_id = ?) AND start_date >= ?",
                                            LeaveRequest::STATUS_REFUSED_BY_RESPONSIBLE, self.id, LeaveRequest::STATUS_REFUSED_BY_DIRECTOR, self.id, Date.today],
                            :order      => "start_date DESC")
  end
  
  # Method to get all services that he is responsible of
  #
  def services_under_responsibility
    jobs.select{ |job| job.responsible and !job.service.nil? }.collect{ |job| job.service }.uniq
  end
  
  # Method to get all subordinates of the employee according to the services that he is responsible of
  #
  def subordinates
    self_and_subordinates.reject{ |n| n.id == id }
  end
  
  # Method to get all subordinates of the employee according to the services that he is responsible of, and himself
  #
  def self_and_subordinates
    services_under_responsibility.collect{ |s| s.members }.flatten.uniq
  end
  
  # Method that return the employee's responsibles according to his service
  #
  def responsibles
    service.nil? ? [] : service.responsibles
  end
  
  # Method that get the leave start date year to know if it's the current year or it's the past year
  #
  def self.leave_year_start_date
    start_date = ConfigurationManager.admin_society_identity_configuration_leave_year_start_date
    year = (Date.today.month >= start_date.split("/").first.to_i)? Date.today.year.to_s : (Date.today.year - 1).to_s
    ("#{year}/#{start_date}").to_date
  end
  
  # Method that return the leave end date according to the leave year start date
  #
  def self.leave_year_end_date
    self.leave_year_start_date + 1.year - 1.day
  end
  
  # Method that return the most recent leave according to the end_date
  #
  def last_leave
    leaves.max_by(&:end_date)
  end
  
  # Method to generate the intranet email
  def intranet_email
    return unless user and user.username
    user.username + "@" + ConfigurationManager.admin_society_identity_configuration_domain
  end
  
  alias_method :email, :intranet_email
  
  # method that generate the username with attribute of the created employee 
  # it take two args which are:
  # obj => class instance (the new employee object, that need to generate a user)
  # val => a string that respect a model like "[Attribut,Option]"
  # - where 'Attribut' is obj attributes like (obj.first_name )
  # - where 'Option' is the number of chars that  will be pick into the Attribut, and put into the final generated username 
  # exemple  obj.last_name => "Mike", obj.first_name => "O'brian", val => .[FIRST_NAME,1].[last_name]
  # generated username => O.mike 
  def pattern(val,obj)
    retour = ""
    open = 0 
    
    # verify if opened '[' are closed with ']'
    unless val.count("[") == val.count("]")
      self.pattern_error = true
      return "Erreur modèle de création de comptes utilisateurs : <br/>- Vous devez fermer les []!!" 
    end
    
    (0..val.size).each do |i|
      # verify if there is forbidden char like "#{" or "|"
      if val[i..i+1] == '#{'
        self.pattern_error = true
        return "Erreur modèle de création de comptes utilisateurs : <br/>- Vous ne devez pas utiliser "+'#'+'{}'
      end
      if val[i..i] == "|"  
        self.pattern_error = true
        return "Erreur modèle de création de comptes utilisateurs : <br/>- Vous ne devez pas utiliser |"
      end
      # verify if there's tabs into tabs
      unless open == 2
        open += 1 if val[i..i] == "[" 
        open -= 1 if val[i..i] == "]"
      else
        self.pattern_error = true
        return "Erreur modèle de création de comptes utilisateurs : <br/>- Vous devez fermer le premier [] avant d'ouvrir le second"
      end
    end
    
    # prepare val to be split with "|"
    val = val.gsub(/\[/,"|")
    val = val.gsub(/\]/,"|")
    # split val to be able to separate each part of val into a tab
    val = val.split("|")
    
    for i in (1...val.size) do
      if(i%2==0)
        retour += val[i]       
      else
        tmp = val[i].split(",")
        # verify if 'Option' is an integer
        if tmp.size>2
          self.pattern_error = true
          return "Erreur modèle de création de comptes utilisateurs : <br/>- trop de virgules dans le pattern, une seule au maximum pour ajouter une Option"
        elsif tmp[0].blank?
          self.pattern_error = true
          return "Erreur modèle de création de comptes utilisateurs : <br/>- Vous devez ajouter au minimum l'Attribut dans les [] "
        elsif tmp.size == val[i].count(",")
          self.pattern_error = true
          return "Erreur modèle de création de comptes utilisateurs : <br/>- Attribut [" + val[i] + "] invalide : vous ne devez utiliser la virgule que pour ajouter l'Option "
        elsif tmp.many?
          tmp[1].size > 15 ? option = tmp[1][0..15] + "..." : option = tmp[1]
          if /^([0-9]){0,15}$/.match(tmp[1].to_s).nil?
            self.pattern_error = true
            return "Erreur modèle de création de comptes utilisateurs : <br/>- Option [ " + option + " ] invalide "
          end
        end
        unless tmp[0].blank?
          txt = tmp[0].downcase
          # verify if 'Attribut' is valid
          if obj.respond_to?(txt) and Employee::METHODS[obj.class.name].include?(txt.downcase)
            if tmp.size==2
              for j in (1...tmp.size)  
                  # test the case of the 'Attribut'            
                  if tmp[0]==tmp[0].upcase
                    tmp[0].downcase!
                    # send the 'Attribut' name and truncate it with the Option that give us the length 
                    txt = obj.send(tmp[0])[0...tmp[1].to_i].strip_accents
                    retour += txt.upcase
                  else
                    # send the 'Attribut' name and truncate it with the Option that give us the length
                    # replace the spaces with  "_" cf=> .gsub(/\x20/,"_")
                    txt = obj.send(tmp[0])[0...tmp[1].to_i].gsub(/\x20/,"_").strip_accents
                    retour += txt.downcase
                  end 
              end 
            else
              # verify a second time the 'Attribut' because if there is a coma with nil 'Option', the split don't see it takes two values
              # then we need to raise that the 'Attribut' is following by a coma 
              if obj.respond_to?(val[i].downcase)
                tmp = val[i].downcase 
              else
                self.pattern_error = true
                return "Erreur modèle de création de comptes utilisateurs : <br/>- Attribut [" + val[i] + "] invalide : vous ne devez utiliser la virgule que pour ajouter l'Option "
              end
              
              txt = obj.send(tmp)
              if txt.blank?
                self.pattern_error = true
                return nil
              end
              
              txt.gsub(/\x20/,"_").strip_accents
              if val[i] == val[i].upcase
                retour += txt.upcase
              else
                retour += txt.downcase
              end
            end
          else
             self.pattern_error = true
             return "Erreur modèle de création de comptes utilisateurs : <br/>- Attribut ["+ tmp[0] +"] invalide : attribut inexistant ou non autorisé "
          end
        end  
      end
    end
      self.pattern_error = false
      return retour.to_s
  end
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def employee_sensitive_data=(sensitive_attributes)
    if employee_sensitive_data.nil?
      self.build_employee_sensitive_data(sensitive_attributes)
    else
      self.employee_sensitive_data.attributes = sensitive_attributes
    end
  end
  
  # this method permit to save the iban of the employee when it is passed with the employee form
  # TODO test
  def iban_attributes=(iban_attributes)
    self.employee_sensitive_data = {} if employee_sensitive_data.nil?
    if iban_attributes[:id].blank?
      self.employee_sensitive_data.build_iban(iban_attributes)
    else
      self.employee_sensitive_data.iban.attributes = iban_attributes
    end 
  end
  
  # TODO test
  def family_situation_id=(family_situation_id)
    self.employee_sensitive_data = {} if employee_sensitive_data.nil?
    self.employee_sensitive_data.family_situation_id = family_situation_id
  end
  
  # TODO test
  def private_number_attributes=(number_attributes)
    self.employee_sensitive_data = {} if employee_sensitive_data.nil?
    self.employee_sensitive_data.number_attributes = number_attributes
  end
  
  # workaround to permit to pass an employee as address owner (employee_sensitive_data is the real owner)
  def self.one_or_many
    EmployeeSensitiveData.one_or_many
  end
  
  # TODO test
  def address_attributes=(address_attributes)
    self.employee_sensitive_data = {} if employee_sensitive_data.nil?
    self.employee_sensitive_data.address_attributes = address_attributes
  end
  
  private
  
    # Method to change the case of the first_name and the last_name at the employee's creation
    def case_management
      self.first_name = self.first_name.mb_chars.capitalize
      self.last_name = self.last_name.mb_chars.upcase
    end

    def save_employee_sensitive_data
      employee_sensitive_data.save(false) if employee_sensitive_data
    end
  
    def build_associated_resources
      if user.nil?
        raise "ConfigurationManager seems to be not yet initialized in #{self}:#{self.class}" unless ConfigurationManager.respond_to?(:admin_user_pattern)
        
        # create associated user
        self.build_user(:username => pattern(ConfigurationManager.admin_user_pattern,self), :enabled => false, :password => 'password')
      end
    end
end
