class Employee < ActiveRecord::Base
  has_permissions :as_business_object
  
  # restrict or add methods to be use into the pattern 'Attribut'
  METHODS = {'Employee' => ['last_name','first_name','birth_date'], 'User' =>[]}

  # Accessors
  cattr_accessor :pattern_error,:form_labels
  @@pattern_error = false

  @@form_labels = Hash.new
  @@form_labels[:civility]                = "Civilit&eacute; :"
  @@form_labels[:last_name]               = "Nom :"
  @@form_labels[:first_name]              = "Pr&eacute;nom :"
  @@form_labels[:birth_date]              = "Date de naissance :"
  @@form_labels[:family_situation]        = "Situation familiale :"
  @@form_labels[:social_security_number]  = "N&deg; s&eacute;curit&eacute; sociale :"
  @@form_labels[:email]                   = "Email personnel :"
  @@form_labels[:society_email]           = "Email professionnel :"
  @@form_labels[:service]                 = "Service :"
  
  
  # Relationships
# TODO Add a role to the user when create an employee => for permissions 

  belongs_to  :family_situation
  belongs_to  :civility
  belongs_to  :user
  belongs_to  :service
  has_one     :address, :as => :has_address
  has_one     :iban, :as => :has_iban
  has_one     :job_contract
  has_many    :leaves, :class_name => "Leave"
  has_many    :checkings

  has_many    :contacts_owners, :as => :has_contact
  has_many    :contacts, :source => :contact, :through => :contacts_owners
  
  has_many    :numbers, :as => :has_number
  has_many    :premia, :order => "created_at DESC"
  has_many    :employees_jobs
  has_many    :jobs, :through => :employees_jobs
  
  
  # Validates
  validates_presence_of :family_situation_id, :civility_id, :last_name, :first_name
  validates_presence_of :family_situation, :if => :family_situation_id
  validates_presence_of :civility, :if => :civility_id
  validates_presence_of :service, :if => :service_id
  validates_format_of :social_security_number, :with => /^([0-9]{13}\x20[0-9]{2})*$/
  validates_format_of :email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/
  validates_format_of :society_email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/
  validates_associated :iban, :address, :job_contract, :user, :contacts, :numbers, :premia, :checkings #, :services, :jobs
  validate :responsible_job_limit, :if => :service
  
  # Callbacks
  before_validation_on_create :build_associated_resources
  before_save :case_managment
  after_update :save_iban, :save_numbers, :save_address
  
  # Method to manage that there's no more than 2 responsible jobs by service
  def responsible_job_limit
    unless self.service.nil?
      errors.add_to_base("Too much responsibles for #{'self.service.name'}") if self.service.responsibles.size > 2
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
#    leave_year_start_date = get_leave_year_start_date + n.year                                                               
#    leave_year_end_date =  leave_year_start_date + 1.year - 1.day
#    total = get_total_leave_days(n)
#    get_leaves_for_choosen_year(n).each do |l|
#      total -= l.duration
#      total += l.duration(leave_year_end_date, l.end_date) - 1 if l.end_date > leave_year_end_date
#      total += l.duration(l.start_date, leave_year_start_date) - 1 if l.start_date < leave_year_start_date
#    end
#    return total
#  end
  
#  # just rename a method to make the call, more human readable
#  def leaves_days_left_for_past_year
#    leaves_days_left -1
#  end

#  # method to get the current total of leave days available
#  def get_total_leave_days(n = 0)
#    leave_year_start_date = get_leave_year_start_date + n
#    positive_difference = (leave_year_start_date.month > Date.today.month)? 12 : 0
#    months = Date.today.month - leave_year_start_date.month + positive_difference + 1
#    months = 12 if n < 0 # all days are already acquired if it's about past year
#    months = 0 if n > 0 # no days are acquired if it's about next year
#    ConfigurationManager.admin_society_identity_configuration_leave_days_credit_per_month * months
#  end
 
  # method to get leaves for choosen leave year
  # n => permit to target a leave year .
  #   #=> default is 0 and represent current leave year
  #   #=> negative value represente shift to the past
  #   #=> positive value represente shift to the future
  # all to true permit to get leaves including cancelled ones
  #
  def get_leaves_for_choosen_year(n, all = false)
    leave_year_start_date = self.class.get_leave_year_start_date + n.year                                                               
    leave_year_end_date = leave_year_start_date + 1.year - 1.day
    collection = (all)? Leave.all : Leave.actives
    collection.reject {|n| !(n.end_date > leave_year_start_date and n.start_date < leave_year_end_date and n.employee_id==self.id)}
  end
  
  # Method to get all services that he is responsible of
  #
  def services_under_responsibility
    result = []
    jobs.each {|job| result << job.service if job.responsible}
    result
  end
  
  # Method to get all subordinates of the employee according to the services that he is responsible of
  #
  def subordinates
    result = []
    services_under_responsibility.each {|service| result += service.members }
    result.uniq.reject {|n| n.id == id}
  end
  
  # Method that get the leave start date year to know if it's the current year or it's the past year
  def self.get_leave_year_start_date
    leave_year_start_date = ConfigurationManager.admin_society_identity_configuration_leave_year_start_date
    year = (Date.today.month >= leave_year_start_date.split("/").first.to_i )? Date.today.year.to_s : (Date.today.year - 1).to_s
    (leave_year_start_date + "/#{year}").to_date
  end
  
  # Method to change the case of the first_name and the last_name at the employee's creation
  def case_managment
    self.first_name.capitalize!
    self.last_name.upcase!
  end
  
  #OPTIMIZE why don't put this method in a named_scope?
  # Method to find active employees
  def self.active_employees
    Employee.find(:all,:include => [:job_contract] , :conditions => ['job_contracts.departure is null', Time.now])
  end
  
  # Method to generate the intranet email
  def intranet_email
    self.user.username + "@" + ConfigurationManager.admin_society_identity_configuration_domain
  end
  
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
    # split val to can separate each part of val into a tab
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
        elsif tmp.size>1
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
  
  #FIXME this method should not work properly!
  def manager(service_id)
    EmployeesService.find(:all,:conditions => ["service_id=? ,responsable=?", service_id, true])
    manager = Employee.find(tmp.employee_id)
    return manager
  end
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end
  
  #OPTIMIZE this method return an array of numbers. why not return objects instead of numbers? and why don't put this method in the Service model???!
  def responsable?(service_id)
    tmp = EmployeesService.find(:all,:conditions => ["service_id=? and responsable=?",service_id,1 ])
    manager = []
    tmp.each do |t|
      e = Employee.find(t.employee_id)
      manager << e.id
    end
    return manager
  end
  
  #OPTIMIZE what this method is doing here ?!!?
  def format_text(line_length,text)
    t_end = text.size
    line_end = 0
    formated_text=""
      while line_end < t_end
        formated_text+=text[line_end..line_end + line_length]+ "\n"
        
        line_end += line_length
      end
    formated_text  
  end
  

  # this method permit to save the iban of the employee when it is passed with the employee form
  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = self.build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end 
  end

  # this method permit to save the address of the employee when it is passed with the employee form
  # we use address_attributes.first because the partial he also use to define mutiple addresses but for the employee there is only 
  # one that's why we use the only one address in the array
  def address_attributes=(address_attributes)
    if address_attributes.first[:id].blank?
      self.address = self.build_address(address_attributes.first)
    else

      self.address.attributes = address_attributes.first
    end    
  end
  
  # this method permit to save the numbers of the employee when it is passed with the employee form
  def number_attributes=(number_attributes)
    number_attributes.each do |attributes|
      if attributes[:id].blank?
        self.numbers.build(attributes)
      else
        number = self.numbers.detect { |t| t.id == attributes[:id].to_i} 
        number.attributes = attributes
      end
    end
  end
  
  private
  
    def save_numbers
      self.numbers.each do |number|
        if number.should_destroy?    
          number.destroy    
        else
          number.save(false)
        end
      end 
    end  
    
    def save_iban
       self.iban.save(false)
    end

    def save_address
      self.address.save(false)
    end
  
    def build_associated_resources
      raise "ConfigurationManager seems to be not yet initialized in #{self}:#{self.class}" unless ConfigurationManager.respond_to?(:admin_user_pattern)
      
      # create associated user
      user = build_user(:username => pattern(ConfigurationManager.admin_user_pattern,self), :password =>"P@ssw0rd")
      
      # create empty job contract
      job_contract = build_job_contract
    end
end
