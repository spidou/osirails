class DocumentVersion < ActiveRecord::Base
  
  include Permissible
  validates_presence_of :name
  
  belongs_to :document
  
  def path
    @document_original = self.document
    @document_original.owner_class + "/" + @document_original.file_type_id.to_s + "/" + @document_original.id.to_s + "/"
  end
  
  def version
    self.document.document_versions.index(self)
  end
  
  def extension 
    self.document.extension
  end
  
  def mime_type
    File.mime_type?("#{self.path}#{self.id}.#{self.extension}")
  end
  
  ## Create thumbnails
  def create_thumbnails
    require 'RMagick'
    @document_original = Document.find(self.document.id)
    if Document.image_mime_types.include?(@document_original.mime_type)
                  
      path = "documents/#{@document_original.owner_class.downcase}/#{@document_original.file_type_id}/#{@document_original.id}" 
      thumbnail = Magick::Image.read("#{path}/#{@document_original.document_versions.index(self) + 1}.#{@document_original.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{@document_original.extension}")
    end
  end
  
  ## Create preview format
  def create_preview_format
    require 'RMagick'
    @document_original = Document.find(self.document.id)
    if Document.image_mime_types.include?(self.mime_type)
      
      path = "documents/#{@document_original.owner_class.downcase}/#{@document_original.file_type_id}/#{@document_original.id}" 
      image = Magick::Image.read("#{path}/#{@document_original.document_versions.index(self) + 1}.#{@document_original.extension}").first
      image.resize_to_fit!(770, 450)
      image.write("#{path}/#{self.id}_770_450.#{self.extension}")
    else
      return false
    end
  end
  
end