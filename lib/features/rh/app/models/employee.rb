class Employee < ActiveRecord::Base
  acts_as_file
  include Permissible
  
  # restrict or add methods to be use into the pattern 'Attribut'
  METHODS = {'Employee' => ['last_name','first_name','birth_date'], 'User' =>[]}
  
  cattr_accessor :pattern_error
  @@pattern_error = false
  
  
  
  # Relationships
# TODO Add a role to the user when create an employee => for permissions 

  belongs_to :family_situation
  belongs_to :civility
  has_one :address, :as => :has_address
  has_one :iban, :as => :has_iban
  has_one :job_contract
  has_one :user
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact, :class_name => "ContactsOwners"
  has_many :contacts, :source => :contact, :foreign_key => "contact_id", :through => :contacts_owners, :class_name => "Contact"
  
  has_many :numbers, :as => :has_number
  has_many :premia
  has_many :employees_services
  has_many :services, :through => :employees_services
  has_and_belongs_to_many :jobs
  
  # Validates
  validates_presence_of :last_name, :first_name, :message => "ne peut être vide"
  validates_format_of :social_security_number, :with => /^([0-9]{13}\x20[0-9]{2})*$/,:message => "format numéro de sécurité social incorrect"
  validates_format_of :email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,:message => "format adresse email incorrect"
  validates_format_of :society_email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,:message => "format adresse email incorrect"
  
  # Callbacks
  after_create :user_create_methode
  before_save :case_managment
  
  # Method to change the case of the first_name and the last_name at the employee's creation
  def case_managment
    self.first_name.capitalize!
    self.last_name.upcase!
  end
  
  # Method to find active employees
  def self.active_employees
    Employee.find(:all,:include => [:job_contract] , :conditions => ['job_contracts.end_date is null or job_contracts.end_date> ?', Time.now])
  end
  
  # Method to generate the intranet email
  def intranet_email
    email = self.user.username + "@" + ConfigurationManager.admin_society_identity_configuration_domain
  end
  
  # method that generate the username with attribute of the created employee 
  # it take two args that are:
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
              txt = obj.send(tmp).gsub(/\x20/,"_").strip_accents
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
  
   
  
  def manager(service_id)
    EmployeesService.find(:all,:conditions => ["service_id=? ,responsable=?", service_id, true])
    manager = Employee.find(tmp.employee_id)
    return manager
  end
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end
  
  def user_create_methode
    User.create(:username => pattern(ConfigurationManager.admin_user_pattern,self), :password =>"P@ssw0rd",:employee_id => self.id)
    JobContract.create(:start_date => "", :end_date => "", :employee_id => self.id, :employee_state_id => "",:job_contract_type_id => "" )  
  end 
  
  def responsable?(service_id)
    tmp = EmployeesService.find(:all,:conditions => ["service_id=? and responsable=?",service_id,1 ])
    manager = []
    tmp.each do |t|
      e = Employee.find(t.employee_id)
      manager << e.id
    end
    return manager
  end
  
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
  
end
