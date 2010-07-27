class Content < ActiveRecord::Base
  has_permissions :as_business_object
  
  serialize :contributors
  
  belongs_to :menu
  belongs_to :author, :class_name => "User"
  
  has_many :versions, :class_name => "ContentVersion", :dependent => :destroy
  
  validates_presence_of :title
  
  # for pagination : number of instances by index page
  CONTENTS_PER_PAGE = 15
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:title]       = "Titre :"
  @@form_labels[:description] = "Description :"
  
  before_save :delete_duplicate_contributors
  
  def menu_attributes=(menu_attributes)
    self.menu = (self.menu.nil? ? Menu.new(menu_attributes) : self.menu.build(menu_attributes))
  end
  
  private
    def delete_duplicate_contributors
      self.contributors.uniq! unless self.contributors.nil?
    end
end
