class User < ActiveRecord::Base
  before_save :username_unicity
  
  # Requires
  require "digest/sha1"

  # Relationships
  has_and_belongs_to_many :roles
  belongs_to :employee
  
  # Validates
  validates_each :password do |record, attr, value|
    unless record.id.nil?
      record.errors.add attr, "ne doit pas être votre ancien mot de passe" if Digest::SHA1.hexdigest(value) == User.find(record['id']).password
    end
  end
  validates_presence_of :username, :message => "ne peut être vide"
  with_options :if => :should_update_password? do |user|
    user.before_save :password_encryption 
    user.validates_presence_of :password, :message => "ne peut être vide "
    user.validates_confirmation_of :password, :message => "ne correspondent pas "
    # manage the error that occure when reset database with admin_actual_password_policy that is empty
    begin
      # find the index of the actual selected regex to choose the good one into the db
      actual = ConfigurationManager.admin_actual_password_policy
      reg = Regexp.new(ConfigurationManager.admin_password_policy[actual])
      # replace the "l" by "d" into 'admin_actual_password_policy' to find the message into admin password_policy (cf. config.yml) concerning the regexp name ex: "d1" message for "l1" regex 
      message = ConfigurationManager.admin_password_policy[ConfigurationManager.admin_actual_password_policy.gsub(/l/,"d")]
      user.validates_format_of :password, :with => reg ,:message => message 
      

      # user.validate :must_be_different
                                                         
      # user.validates_format_of :password, :with => /^(a.A){32}$/ ,:message =>  " ne doit pas être votre ancien mot de passe" , :if => :same_password?
    rescue Exception =>  e
      puts "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
    end
  end
  
  # Accessors
  attr_accessor :updating_password
 

  # Method to encrypt a string
  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end
  
  # Method to encrypt the password to the data base
  def password_encryption
    self.password = encrypt(self.password)
  end
  
  # Method to verify if the password pass by argument is the same as the password in the database
  def compare_password(password)
    self.password == encrypt(password)
  end
  
  # Method to verify if the password is empty or not
  def should_update_password?
    updating_password || new_record?
  end
  
  # Update the column last_connection when a user loggin
  def update_connection
    update_attribute('last_connection', Time.now)
    update_activity
  end
  
  # Update the column last_activity whenever a user request for a page
  def update_activity
    update_attribute('last_activity', Time.now)
  end
  
  def expired?
    return true if self.password_updated_at.nil?
    return false if ConfigurationManager.admin_password_validity == 0
    return true if (self.password_updated_at.to_date + ConfigurationManager.admin_password_validity.day).to_time < Time.now
  end
  
  def username_unicity
    @users = User.find(:all)
    inc = 2
    unique = 0
    for user in @users
      if user.username.downcase == self.username.downcase and user.id != self.id
        while unique < @users.size
          unique = 0
          for user2 in @users
            if user2.username.downcase == self.username.downcase + inc.to_s and user.id != self.id
              inc+=1    
            else  
              unique+=1
            end
          end
        end
        self.username += inc.to_s  
      end
    end
  end
  
  
# TODO delete the Add link that been used for dev purposes
end