class Content < ActiveRecord::Base
  include Permissible

  # Serialize
  serialize :contributors
  
  # Relationship
  belongs_to :menu
  belongs_to :author, :class_name => "User"
  has_many :versions, :class_name => "ContentVersion", :dependent => :destroy

    # Validation Macros
  validates_presence_of :title, :message => "ne peut être vide"
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:title] = "Titre :"
  @@form_labels[:description] = "Description :"
end