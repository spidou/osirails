class Document < ActiveRecord::Base
  
  include Permissible
  
  ## Relationship
  belongs_to :file_type
  has_many :document_versions
  belongs_to :has_document, :polymorphic => true
  
  ## Validates
#  validates_presence_of :name
  
  ## Instance accessor
  attr_accessor :is_new
  attr_accessor :owner  
  attr_accessor :file
  attr_accessor  :tag_list
  
  ## Class accessor
  attr_accessor :models
  attr_accessor :image_extensions
  
  ## Plugins
  acts_as_taggable  
  
  @image_extensions = ["jpg", "jpeg","png","gif"]
  @models = []
  
  # Add the model name into models array
  def self.add_model(model)
    @models << model
  end
  
  ## Return model array that can get document
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
  
  ## Return owner class
  def owner_class
    self.has_document.class.name.downcase
  end
  ## Return file of document
  def get_file
    if self.is_new
      return file
    else
      path = "documents/" + self.path +  self.id.to_s + "." + self.extension
      return File.open((path), "r")
    end
    return false
  end
  
  ## Create thumbnails
  def create_thumbnails
    require 'RMagick'
    if Document.image_extensions.include?(self.extension)     
      path = "documents/#{self.owner_class.downcase}/#{self.file_type.id}/"
      thumbnail = Magick::Image.read("#{path}#{self.id}.#{self.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{self.extension}")
    end
  end
  
  ## Return document path
  def path
    #    unless self.class == OrdersSteps
    return self.owner_class + "/" + self.file_type_id.to_s + "/"
    #    else
    #      return "order/" + self.file_type_id.to_s + "/"
    #    end
  end
  
  ## Override new method
  def self.new(document = nil)
    unless document.nil?
      unless document[:owner].nil?      
        ## Store file extension
        document_extension = document[:datafile].original_filename.split(".").last unless document[:datafile].blank?
        document_extension = File.mime_type?(File.open(document[:datafile].path, "r")).strip.split("/")[1].split(";")[0].to_s unless document[:datafile].blank?
    
        ## affect document_name with original document name if associated textfield is undefined 
        document[:name].blank? ? document_name = ((a = document[:datafile].original_filename.split("."); a.pop; a.to_s) unless document[:datafile].blank?) : document_name = document[:name]
    
        @document =super(
          :name => document_name , 
          :description => document[:description], 
          :extension => document_extension)
        @document.file_type = FileType.find(document[:file_type_id]) unless document[:file_type_id].nil?
        @document.owner = document[:owner]
        @document.file = document[:datafile] unless document[:datafile].blank?
        @document.is_new = true
        return @document
      else
        raise "Document require owner attribute. example : Document.new(:owner => Employee.last)"
      end
    else
      return false
    end
  end
  
  def self.create_all(documents, owner)
    if documents.keys.size.to_i > 0
      document_objects = []
      documents.keys.size.to_i.times do |i|
        unless documents["#{i+1}"][:valid] == "false"
          documents["#{i+1}"][:owner] = owner
          document_objects << Document.new(documents["#{i+1}"])
        end
      end
      return document_objects
    end   
  end
  
  ## Override update_attributes method
  def update_attributes(document = nil)
    unless document.nil?
      unless document[:upload].nil?
        unless document[:upload][:datafile].blank?
          self.file = document[:upload][:datafile]
          if self.valid?
            ## Store tags list
            tag_list = document.delete("tag_list").split(",")
        
            ## Creation of document_version          
            path = "documents/" + self.path + "/" +  self.id.to_s + "/"
            file_response = FileManager.upload_file(:file => document[:upload], :name => (self.document_versions.size + 1).to_s, 
              :directory => path, :file_type_id => self.file_type.id)
            if file_response
              @document_version = DocumentVersion.create(:name => self.name, :description => self.description, :versioned_at => self.updated_at)      
        
              ## Add tag_list for document
              self.tag_list = tag_list
          
              document.delete("upload")
              self.document_versions << @document_version
              @document_version.create_thumbnails(self.id)
              super(document)
              return self
            end
          else
            return self
          end
        else
          self.errors.add("Le fichier", "n'a pas été trouvé")
          return self
        end        
      else
        return false
      end
    else
      super ## document.nil?
    end
  end
  
  ## Override valid? method
  def valid?
    unless self.file_type.nil?
      unless self.file
        self.errors.add("Le fichier", "n'a pas été trouvé")
        return false
      end
      
      if FileManager.valid_mime_type?(self.file, self.file_type.id)
        return super     
      else
        ## If document mime_type is invalid for his file_type
        self.errors.add("Le type", "du fichier ne correspond pas avec son extension")
        return false
      end
    else
      ## If his file_type is undefine, it impossible to test if it's a valid document
      return false
    end
    return false
  end
  
  ## Override save method
  def save()
    if self.is_new == true
      if self.owner.valid?
        
        unless self.file.nil?
          unless self.file.blank?
        
            ## Store all possible extension for file
            possible_extensions = []
            self.file_type.file_type_extensions.each {|f| possible_extensions << f.name}
          
            if self.valid?
              super
              path = "documents/" + self.owner.class.name.downcase + "/" + self.file_type.id.to_s.downcase + "/"
              file_response = FileManager.upload_file(:file => {:datafile => self.file}, :name => self.id.to_s, 
                :directory => path, :file_type_id => self.file_type.id)
              ## If file succefuly create
              if file_response == true
                
                ## Add tag_list for document
                unless self.tag_list.nil?
                  self.tag_list.each {|tag| self.tag_list << tag.strip} 
                  #FIXME Verify if it's necessary
                  self.tag_list.uniq!
                end
                self.is_new = false
                return true            
              else
                self.destroy
                return file_response
              end
            end      
          else
            return false
          end
        else
          return false
        end ## file.nil?
      else
        return false
      end ## owner.valid?
    else
      super
    end
  end
  
end