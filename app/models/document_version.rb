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
  
  ## Create thumbnails
  def create_thumbnails(document_id)
    require 'RMagick'
    @document_original = Document.find(document_id)
        
    if Document.image_extensions.include?(@document_original.extension)
      path = "documents/#{@document_original.owner_class.downcase}/#{@document_original.file_type_id}/#{@document_original.id}" 
      thumbnail = Magick::Image.read("#{path}/#{@document_original.document_versions.index(self) + 1}.#{@document_original.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{@document_original.extension}")
    end
  end
  
end