class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  # Validates
  validates_uniqueness_of :username, :message => "existe déjà"
  validates_presence_of :username, :password, :message => "ne peut être vide"
  validates_confirmation_of :password, :message => "ne correspondent pas≈"
  before_save :password_encryption
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

end
