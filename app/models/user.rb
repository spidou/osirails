class User < ActiveRecord::Base

  before_save :username_unicity
  

  # Requires
  require "digest/sha1"

  # Relationships
  has_and_belongs_to_many :roles
  
  # Validates
  validates_each :password do |record, attr, value|
    unless record.id.nil?
      record.errors.add attr, "ne doit pas être votre ancien mot de passe" if Digest::SHA1.hexdigest(value) == User.find(record['id']).password
    end
  end
  
  validates_presence_of :username
  
  with_options :if => :should_update_password? do |user|
    user.before_save :password_encryption
    user.validates_presence_of :password
    user.validates_confirmation_of :password
    # manage the error that occure when reset database with admin_actual_password_policy that is empty
    # find the index of the actual selected regex to choose the good one into the db
    raise "ConfigurationManager seems to be not yet initialized in #{self}:#{self.class}" unless ConfigurationManager.respond_to?(:admin_actual_password_policy)
    
    actual = ConfigurationManager.admin_actual_password_policy
    reg = Regexp.new(ConfigurationManager.admin_password_policy[actual])
    # replace the "l" by "d" into 'admin_actual_password_policy' to find the message into admin password_policy (cf. config.yml) concerning the regexp name ex: "d1" message for "l1" regex 
    message = ConfigurationManager.admin_password_policy[ConfigurationManager.admin_actual_password_policy.gsub(/l/,"d")]
    user.validates_format_of :password, :with => reg, :message => message
  end
  
  # CallBacks
  before_save    :change_password_updated_at
  before_destroy :can_be_destroyed?

  # Accessors
  # set up this variable to 'true' if you want to update password
  attr_accessor :updating_password
  
  # after_find store the password after each find request in that variable
  attr_accessor :old_encrypted_password
  
  # this variable must be set at "1" if we want to force password expiration (by setting at nil 'password_updated_at')
  attr_accessor :force_password_expiration
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:username] = "Nom du compte utilisateur :"
  @@form_labels[:password] = "Mot de passe :"
  @@form_labels[:password_confirmation] = "Confirmation du mot de passe :"
  @@form_labels[:enabled] = "Activ&eacute; :"
  @@form_labels[:last_connection] = "dernière connection :"
  @@form_labels[:roles] = "R&ocirc;les :"
  @@form_labels[:force_password_expiration] = "Demander &agrave; l&apos;utilisateur un nouveau mot de passe à sa prochaine connexion :"
 
  # Search Plugin
  has_search_index  :additional_attributes => {"expired?" => "boolean" , "password_updated_at" => "datetime"},
                    :only_sub_models => ["Role"]
                    
  
  # store old encrypted password to be aware if a new password is given
  def after_find
    self.old_encrypted_password = self.password
  end
  
  # Method to verify if the password pass by argument is the same as the password in the database
  def compare_password(password)
    self.password == encrypt(password)
  end
  
  # Method to check is the password should be updated or not
  def should_update_password?
    updating_password || new_record?
  end
  
  def force_password_expiration?
    force_password_expiration.to_i == 1
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
  
  def enabled?
    enabled == true
  end
  
  def expired?
    return true if self.password_updated_at.nil?
<<<<<<< HEAD:app/models/user.rb
    return false if ConfigurationManager.admin_password_validity == 0
    (self.password_updated_at.to_date + ConfigurationManager.admin_password_validity.day).to_time < Time.now
=======
    if ConfigurationManager.admin_password_validity == 0
      false
    elsif (self.password_updated_at.to_date + ConfigurationManager.admin_password_validity.day).to_time < Time.now
      true
    else
      false
    end
>>>>>>> Coding has_search_index plugin and test in some models:app/models/user.rb
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

  def can_be_destroyed?
    true #TODO check if the user can be destroyed...
  end

  private
    def change_password_updated_at
      if force_password_expiration?
        self.password_updated_at = nil
      elsif should_update_password?
        self.password_updated_at = Time.now
      end
    end
    
    ## determine if we want to update password or not
    #def updating_password?
    #  puts "> #{self.password.blank?.inspect} > #{self.password} > #{self.old_encrypted_password}"
    #  return false if self.password.blank?
    #  return false if self.password == self.old_encrypted_password
    #  return true
    #  #raise (!self.password.blank? and self.password != self.old_encrypted_password).inspect
    #  ##if !self.password.blank? and encrypt(self.password) != self.old_encrypted_password
    #  ##  raise (!self.password.blank? and encrypt(self.password) != self.old_encrypted_password).inspect
    #  ##end
    #  #!self.password.blank? and self.password != self.old_encrypted_password
    #end
    
    # Method to encrypt a string
    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end

    # Method to encrypt the password to the data base
    def password_encryption
      self.password = encrypt(self.password)
    end
end
