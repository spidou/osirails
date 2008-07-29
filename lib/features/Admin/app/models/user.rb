class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  before_save :password_encryption
  # Validates
  validates_uniqueness_of :username, :message => "existe déjà"
  validates_presence_of :username, :message => "ne peut être vide"
  with_options :if => :should_update_password? do |user|
    user.validates_presence_of :password, :message => "ne peut être vide"
    user.validates_confirmation_of :password, :message => "ne correspondent pas"
  end
  # Accessors
  attr_accessor :updating_password
  # Requires
  require "digest/sha1"
  
  # Method to encrypt the password to the data base
  def password_encryption
    self.password = Digest::SHA1.hexdigest(self.password)
  end
  
  # Method to verify if the password pass by argument is the same as the password in the database
  def compare_password(new_password)
    self.password == Digest::SHA1.hexdigest(new_password)
  end
  
  # Method to verify if the password is empty or not
  def should_update_password?
    updating_password || new_record?
  end

end
