class GraphicItemSpoolItem < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationships
  belongs_to :user
  belongs_to :graphic_item
 
  # Validations
  validates_uniqueness_of :graphic_item_id, :scope => [ :user_id, :file_type ]
  
  validates_presence_of :file_type, :graphic_item_id, :user_id
  validates_presence_of :graphic_item,  :if => :graphic_item_id
  validates_presence_of :user,          :if => :user_id
  
  named_scope :spool_items_by_user, lambda{ |user| { :conditions => ['user_id = ?', user.id], :order => 'created_at DESC' } }
  
  # Callbacks
  before_create  :generate_link_path
  after_create   :create_link
  before_update  :can_be_edited?
  before_destroy :remove_link
  
  # Constants
  SPOOL_DIRECTORY = "#{RAILS_ROOT}/assets/sales/spool"
   
  # Methods  
  def can_be_edited?
    false
  end
  
  def create_link
    unless system "ln -s \"#{graphic_item_path}\" \"#{path}\""
      logger.error "Échec à la création du raccourci vers le fichier \"#{self.file_type}\" du GraphicItem n° #{graphic_item_id} (#{graphic_item.name})"
    end
  end
  
  def remove_link
    unless system "rm -f \"#{path}\""
      logger.error "Échec à la suppression du raccourci vers le fichier \"#{file_type}\" du GraphicItem n° #{graphic_item_id} (#{graphic_item.name})"
    end
  end
  
  def generate_link_path
    self.path = "#{SPOOL_DIRECTORY}/#{user_spool_directory}/#{I18n.l(Time.now, :format => "%Y-%b-%d-%Hh%M")}_#{customer_name}_#{order_title}_#{graphic_item_name}(#{graphic_item_id})#{graphic_item_extension}"
  end
    
  def user_spool_directory
    user.id.to_s
  end
  
  def customer_name
    graphic_item.order.customer.name.gsub(" ","_")
  end
  
  def order_title
    graphic_item.order.title.gsub(" ","_")
  end
  
  def graphic_item_name
    graphic_item.name_was.gsub(" ","_")
  end
  
  def graphic_item_path
    graphic_item.send("current_#{file_type}").path
  end
  
  def graphic_item_extension
    File.extname(graphic_item_path)
  end
end
