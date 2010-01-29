class GraphicItemVersion < ActiveRecord::Base
  has_permissions :as_business_object, :class_methods => [:view]
  
  # Relationships
  belongs_to :graphic_item

#  TODO when press proofs will be implemented  
#  has_many :press_proof_items
#  has_many :press_proofs, :through => :press_proof_items
  
  # paperclip plugin
  has_attached_file :image, 
                    :styles => { :medium => "640x400>",
                                 :thumb => "100x100#" },
                    :path => ":rails_root/assets/graphic_item_versions/:id/image/:style.:extension",
                    :url => "/graphic_item_versions/:id/:style.:extension"
                    
  has_attached_file :source, 
                    :path => ":rails_root/assets/graphic_item_versions/:id/source/:basename.:extension",
                    :url => "/graphic_item_versions/:id/source.:extension"                
  
  # paperclip plugin validations
  validates_attachment_presence     :image
  validates_attachment_content_type :image, :content_type => ['image/jpg', 'image/png', 'image/jpeg', 'image/x-png', 'image/p-jpeg']
  validates_attachment_size         :image, :less_than => 10.megabytes

  # Validations
  validate                 :validates_source_attachment_content_type
  validates_persistence_of :graphic_item_id, :source_file_name, :source_file_size, :source_content_type, :image_file_name, :image_file_size, :image_content_type
  
  # Methods  
  def validates_source_attachment_content_type
    errors.add(:source, "The source file cannot have a JPG or PNG extension") if ['image/jpg', 'image/png', 'image/jpeg', 'image/x-png', 'image/p-jpeg'].include?(source_content_type)
  end
  
  def formatted_created_at
    created_at.humanize
  end
end
