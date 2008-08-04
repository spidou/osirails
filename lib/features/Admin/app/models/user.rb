class User < ActiveRecord::Base
  # Relationships
  has_and_belongs_to_many :roles
  belongs_to :employee
  
  # Validates
  validates_uniqueness_of :username, :message => "existe déjà"
  validates_presence_of :username, :message => "ne peut être vide"
  with_options :if => :should_update_password? do |user|
    user.before_save :password_encryption
    user.validates_presence_of :password, :message => "ne peut être vide"
    user.validates_confirmation_of :password, :message => "ne correspondent pas"
    # find the index of the actual selected regex to choose the good one into the db
    actual = ConfigurationManager.admin_password_policy["actual"]
    reg = Regexp.new(ConfigurationManager.admin_password_policy[actual])
    # replace the "l" by "d" to find the message concerning the regexp name ex: "d1" message for "l1" regex 
    mess = ConfigurationManager.admin_password_policy[actual.gsub(/l/,"d")]

    user.validates_format_of :password, :with => reg ,:message =>  mess
  end
  
  # Accessors
  attr_accessor :updating_password, :minChar, :maxChar
  # Requires
  require "digest/sha1"
  
  # Method to encrypt a string
  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end
  
  # Method to encrypt the password to the data base
  def password_encryption
    self.password = encrypt(self.password)
  end
  
  # Method to verify if the password pass by argument is the same as the password in the database
  def compare_password(new_password)
    self.password == encrypt(new_password)
  end
  
  # Method to verify if the password is empty or not
  def should_update_password?
    updating_password || new_record?
  end

#  def after_save
#    Employee.create(:first_name =>self.username )
#
#  end
  
  # Update the column last_connection when a user loggin
  def update_connection
    update_attribute('last_connection', Time.now)
    update_activity
  end
  
  # Update the column last_activity whenever a user request for a page
  def update_activity
    update_attribute('last_activity', Time.now)
  end

# TODO delete the Add link that been used for dev purposes
end
