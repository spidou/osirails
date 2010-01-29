class GraphicItemSpoolItem < ActiveRecord::Base
  has_permissions :as_business_object
  
  # Relationships
  belongs_to :user
  belongs_to :graphic_item
 
  # Validations
  validates_uniqueness_of :graphic_item_id, :scope => [:user_id,:file_type]
  validates_presence_of   :graphic_item_id, :user_id
  validates_presence_of   :graphic_item, :if => :graphic_item_id
  validates_presence_of   :user, :if => :user_id
  validates_presence_of   :file_type
  
  # Callbacks
  before_create  :generate_link_path
  after_create   :create_link
  before_update  :avoid_update
  before_destroy :remove_link
  
  # Constants
  SPOOLS_DIRECTORY = "assets/spool"
   
  # Methods  
  def avoid_update
    return false
  end
  
  def create_link
    unless system "ln -s " + graphic_item_path + " " + path
      logger.error "Échec à la création du raccourci vers le fichier #{self.file_type} de l'élément graphique #{self.graphic_item.name} (ID=#{self.graphic_item.id})' "
    end
  end
  
  def remove_link
    unless system "rm -f " + path
      logger.error "Échec à la suppression du raccourci vers le fichier #{file_type} de l'élément graphique #{graphic_item.name} (ID=#{graphic_item.id})' "
    end
  end
  
  def generate_link_path
    self.path = "#{RAILS_ROOT}/#{SPOOLS_DIRECTORY}/#{user_spool_directory}/#{Time.now.strftime("%d%m%y%H%M%S")}_#{customer_name}_#{order_title}_#{order_id}_#{graphic_item_type}_#{graphic_item_name}#{File.extname(graphic_item_path)}"
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
  
  def order_id
    graphic_item.order.id.to_s
  end
  
  def graphic_item_type
    graphic_item.class.name.underscore
  end
  
  def graphic_item_name
    graphic_item.name_was.gsub(" ","_")
  end
  
  def graphic_item_path
    graphic_item.send("current_#{file_type}").path
  end
end
