class User < ActiveRecord::Base
  acts_on_journalization_with :username
  
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
  
  before_save    :change_password_updated_at # that callback must be before 'before_save :password_encryption'
  before_destroy :can_be_destroyed?
  
  with_options :if => :should_update_password? do |user|
    user.before_save :password_encryption
    user.validates_presence_of :password
    user.validates_confirmation_of :password
    # manage the error that occure when reset database with admin_actual_password_policy that is empty
    # find the index of the actual selected regex to choose the good one into the db
    raise NameError, "ConfigurationManager seems to be not yet initialized in #{self}:#{self.class}" unless ConfigurationManager.respond_to?(:admin_actual_password_policy)
    #FIXME Add a custom ERROR_CLASS for ConfigurationManager, to catch the error below more precisely 
    
    actual = ConfigurationManager.admin_actual_password_policy
    reg = Regexp.new(ConfigurationManager.admin_password_policy[actual])
    # replace the "l" by "d" into 'admin_actual_password_policy' to find the message into admin password_policy (cf. config.yml) concerning the regexp name ex: "d1" message for "l1" regex 
    message = ConfigurationManager.admin_password_policy[ConfigurationManager.admin_actual_password_policy.gsub(/l/,"d")]
    user.validates_format_of :password, :with => reg, :message => message
  end
  
  # this variable must be set at "1" if we want to force password expiration (by setting at nil 'password_updated_at')
  attr_accessor :force_password_expiration
  
  # Search Plugin
  has_search_index  :additional_attributes => { :expired? => :boolean },
                    :only_attributes       => [ :username, :enabled, :last_connection, :last_activity ]
  
  # Method to verify if the password pass by argument is the same as the password in the database
  def compare_password(password)
    self.password == encrypt(password)
  end
  
  # Method to check is the password should be updated or not
  def should_update_password?
    updating_password? || new_record?
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
    return false if ConfigurationManager.admin_password_validity.to_i == 0
    (self.password_updated_at.to_date + ConfigurationManager.admin_password_validity.to_i.day).to_time < Time.now
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
    
    # determine if we want to update password or not
    def updating_password?
      password != password_was
    end
    
    # Method to encrypt a string
    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end

    # Method to encrypt the password to the data base
    def password_encryption
      self.password = encrypt(self.password)
    end
end
