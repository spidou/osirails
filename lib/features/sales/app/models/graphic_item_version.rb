class GraphicItemVersion < ActiveRecord::Base
  has_permissions :as_business_object, :class_methods => [:view]
  
  # Relationships
  belongs_to :graphic_item

  has_many :press_proof_items
  has_many :press_proofs, :through => :press_proof_items
  
  # paperclip plugin
  has_attached_file :image, 
                    :styles => { :medium  => "640x400>",
                                 :thumb   => "100x100#" }, # be careful !! don't name a style 'source' like the second attachment of GraphicItemVersion, because there are stored in the same directory
                    :path   => ":rails_root/assets/sales/graphic_item_versions/:id/:style.:extension",
                    :url    => "/graphic_item_versions/:id/image/:style"
                    
  has_attached_file :source, 
                    :path => ":rails_root/assets/sales/graphic_item_versions/:id/source.:extension",
                    :url  => "/graphic_item_versions/:id/source"
  
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
  
  def formatted_image_for_press_proof_path
    output_path = "#{File.dirname(image.path)}/formatted_image_for_press_proof#{File.extname(image.path)}"
      unless File.exists?(output_path)
        if `identify -format %h #{image.path}`.to_i > `identify -format %w #{image.path}`.to_i
          `convert #{image.path} -rotate 90 #{output_path}`
        end
      end
    if File.exists?(output_path)
      return output_path
    else
      return image.path
    end
  end  
  
  def position_in_press_proof(press_proof)
    return if new_record?
    press_proof_item = press_proof.press_proof_items.detect{ |i| i.graphic_item_version_id == self.id }
    press_proof_item ? press_proof_item.position : 0
  end
end
