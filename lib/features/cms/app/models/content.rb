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

  # Callbacks
  before_save :delete_duplicate_contributors

  def menu_attributes=(menu_attributes)
    self.menu = (self.menu.nil? ? Menu.new(menu_attributes) : self.menu.build(menu_attributes))
  end

  private

  def delete_duplicate_contributors
    self.contributors.uniq!
  end
end