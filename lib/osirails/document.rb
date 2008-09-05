class Document < ActiveRecord::Base
  belongs_to :file_type
  has_many :document_versions
  belongs_to :has_document, :polymorphic => true
  
  attr_accessor :models
  attr_accessor :image_extensions
  
  acts_as_taggable
  
  @image_extensions = ["jpg", "jpeg","png","gif"]
  @models = []
  
  # Add the model name inton models array
  def self.add_model(model)
    @models << model
  end
  
  def self.models
    @models
  end
  
  def self.add_image_extension(image_extension)
    @image_extensions << image_extension
  end
  
  def self.image_extensions
    @image_extensions
  end
  
  def self.can_have_document(model)
    if @models.include?(model)
      true
    else
      false
    end
  end
  
   # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
  def owner_class
    self.has_document.class.name.downcase
  end
  
  ## Create thumbnails
  def create_thumbnails
    require 'RMagick'
    if Document.image_extensions.include?(self.extension)
      path = "documents/#{self.owner_class.downcase}/#{self.file_type_id}/"
      thumbnail = Magick::Image.read("#{path}/#{self.id}.#{self.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{self.extension}")
    end
  end
  
  def path
    self.owner_class + "/" + self.file_type_id.to_s + "/"
  end
  
end
