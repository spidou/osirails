class DocumentVersion < ActiveRecord::Base
  
  belongs_to :document
  
  def path
    @document_original = self.document
    @document_original.owner_class + "/" + @document_original.file_type_id.to_s + "/" + @document_original.id + "/"
  end
  
  ## Create thumbnails
  def create_thumbnails
    @document_original = self.document
    
    require 'RMagick'
    if Document.image_extensions.include?(@document_original.extension)
      path = "documents/#{@document_original.owner_class.downcase}/#{@document_original.file_type_id}/#{@document_original.id}/"
      thumbnail = Magick::Image.read("#{path}/#{self.id}.#{@document_original.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{@document_original.extension}")
    end
  end
  
end