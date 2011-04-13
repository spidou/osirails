class EmployeeSensitiveData < ActiveRecord::Base
  has_permissions :as_business_object
  has_address :address
  has_numbers
  
  
  belongs_to :employee
  belongs_to :family_situation
  
  has_one :iban, :as => :has_iban
    
  has_many :premia, :order => "created_at DESC"
  
  journalize :attributes        => [:birth_date, :social_security_number, :family_situation_id, :email],
             :subresources      => [:address, :numbers, :iban]
             
  validates_associated :iban, :address
  
  validates_presence_of :family_situation_id
  validates_presence_of :family_situation,     :if => :family_situation_id
  
  validates_format_of :social_security_number,  :with         => /^[0-9]{13}\x20[0-9]{2}$/,
                                                :allow_blank  => false
  validates_format_of :email,                   :with         => /^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/,
                                                :allow_blank  => true
                                                
  has_search_index :only_attributes => [ :email, :birth_date, :social_security_number]
  after_save :save_iban
  
  private
  
    def save_iban
       iban.save(false) if iban
    end
end

