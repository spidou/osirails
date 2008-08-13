class Employee < ActiveRecord::Base

  belongs_to :family_situation
  belongs_to :civility
  has_one :address, :as => :has_address
  has_many :numbers, :as => :has_number
  has_one :iban, :as => :has_iban
  has_many :premia
  has_one :job_contract
  has_one :user 
  has_and_belongs_to_many :services
  has_and_belongs_to_many :jobs
  
  validates_presence_of :last_name,:first_name , :message => "ne peut être vide"
  validates_format_of :social_security, :with => /^([0-9]{13}\x20[0-9]{2})*$/,:message => "format numéro de sécurité social incorrect"
  validates_format_of :email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,:message => "format adresse email incorrect"
  validates_format_of :society_email, :with => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,:message => "format adresse email incorrect"
  
  after_create :user_create_methode
  before_save :case_managment
  
  # Method to chnage the case of the fisrt_name and the last_name at the employee's creation
  def case_managment
    self.first_name.capitalize!
    self.last_name.upcase!
  end
  
  def pattern(pat,obj)
    retour = ""
    val = pat
    val.gsub!(/\{/,"|")
    val.gsub!(/\}/,"|")
    val = val.split("|")
    
    for i in (1...val.size) do
      if(i%2==0)
        retour += val[i]        
      else
        tmp = val[i].split(",")
        txt = tmp[0].downcase
        if obj.respond_to?(txt)  
          if tmp.size==2
            for j in (1...tmp.size)             
                if tmp[0]==tmp[0].upcase
                  tmp[0].downcase!
                  txt = obj.send(tmp[0])[0...tmp[1].to_i]
                  retour += txt.upcase
                else
                  txt = obj.send(tmp[0])[0...tmp[1].to_i].gsub(/\x20/,"_")
                  retour += txt.downcase
                end 
            end 
          else
            tmp = val[i].downcase
            txt = obj.send(tmp).gsub(/\x20/,"_")
            if val[i] == val[i].upcase
              retour += txt.upcase
            else
              retour += txt.downcase
            end
          end
        else
           return retour = "error in attribute name ["+ tmp[0] +"]"
        end
      end
    end
      return retour.to_s
  end
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end
  
  def user_create_methode
    User.create(:username => pattern(ConfigurationManager.admin_user_pattern,self), :password =>"P@ssw0rd",:employee_id => self.id)
    JobContract.create(:start_date => "", :end_date => "", :employee_id => self.id, :employee_state_id => "",:job_contract_type_id => "" )  
  end 
end
